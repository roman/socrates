#!/usr/bin/env bash
# shellcheck shell=bash
#
# Bootstrap helpers for the Socrates sandbox VM. Sourced (or appended) by the
# wrapper packages sandbox-ralph and sandbox-ralph-once.
#
# Expected env (set by the Nix wrapper):
#   SANDBOX_LIMA_YAML            path to lima.yaml in /nix/store
#   SANDBOX_RALPH_INNER_SCRIPT   ralph.sh | ralph-once.sh (the script to run inside the VM)
#
# Expected env (set by the user):
#   CLAUDE_CODE_OAUTH_TOKEN      from `claude setup-token` on the host
set -euo pipefail

INSTANCE="${SANDBOX_INSTANCE:-sandbox-vm}"

sandbox_main() {
  : "${SANDBOX_LIMA_YAML:?internal: SANDBOX_LIMA_YAML not set by wrapper}"
  : "${SANDBOX_RALPH_INNER_SCRIPT:?internal: SANDBOX_RALPH_INNER_SCRIPT not set by wrapper}"
  : "${CLAUDE_CODE_OAUTH_TOKEN:?host must export CLAUDE_CODE_OAUTH_TOKEN (run \`claude setup-token\` first)}"

  PROJECT_ROOT="$(git rev-parse --show-toplevel)"
  PROJECT_NAME="$(basename "$PROJECT_ROOT")"
  HOST_BRANCH="$(git -C "$PROJECT_ROOT" branch --show-current)"

  sandbox_preflight_host
  sandbox_build_image
  sandbox_start_vm

  # Query actual guest home after VM is up (Lima appends .linux/.darwin suffix).
  # Single quotes intentional: $HOME must expand inside the VM, not on the host.
  # shellcheck disable=SC2016
  GUEST_HOME="$(limactl shell "$INSTANCE" -- bash -c 'echo $HOME')"
  GUEST_PROJECT_DIR="$GUEST_HOME/$PROJECT_NAME"

  sandbox_seed_project
  sandbox_ensure_remote

  local ralph_rc=0
  sandbox_run_ralph "$@" || ralph_rc=$?

  if ! sandbox_pull_results; then
    echo "warning: pull from sandbox failed — fetch manually with: git fetch sandbox-vm" >&2
  fi

  exit "$ralph_rc"
}

sandbox_preflight_host() {
  if [ -z "$HOST_BRANCH" ]; then
    echo "error: host is in detached-HEAD state; check out a branch before sandboxing" >&2
    exit 1
  fi
  if [ -n "$(git -C "$PROJECT_ROOT" status --porcelain --untracked-files=no)" ]; then
    echo "error: host worktree has uncommitted changes" >&2
    echo "       commit or stash before running — fast-forward from the VM requires a clean tree" >&2
    git -C "$PROJECT_ROOT" status --short --untracked-files=no >&2
    exit 1
  fi
}

sandbox_build_image() {
  echo ">>> Building sandbox VM image..."
  local out
  out="$(nix build --no-link --print-out-paths "$PROJECT_ROOT#sandbox-vm-image")"
  # nixos-generators qcow-efi places the image at $out/nixos.qcow2 typically;
  # be defensive about the exact name.
  local img=""
  for candidate in "$out/nixos.qcow2" "$out"/*.qcow2 "$out"/*.img; do
    if [ -f "$candidate" ]; then
      img="$candidate"
      break
    fi
  done
  if [ -z "$img" ]; then
    echo "error: could not locate qcow2 in $out" >&2
    ls -la "$out" >&2
    exit 1
  fi
  export SANDBOX_VM_IMAGE="$img"
  echo ">>> Image: $SANDBOX_VM_IMAGE"

  # Lima does not expand {{.Env.X}} in images.location — substitute at runtime.
  RUNTIME_LIMA_YAML="$(mktemp /tmp/sandbox-lima-XXXXXX.yaml)"
  # shellcheck disable=SC2064
  trap "rm -f $RUNTIME_LIMA_YAML" EXIT
  sed "s|__SANDBOX_VM_IMAGE__|$SANDBOX_VM_IMAGE|g" "$SANDBOX_LIMA_YAML" > "$RUNTIME_LIMA_YAML"
}

sandbox_start_vm() {
  if limactl list -q | grep -qx "$INSTANCE"; then
    local status
    status="$(limactl list -f '{{.Status}}' "$INSTANCE" 2>/dev/null)"
    if [ "$status" != "Running" ]; then
      echo ">>> Starting existing VM '$INSTANCE'"
      limactl start "$INSTANCE"
    else
      echo ">>> VM '$INSTANCE' already running"
    fi
  else
    echo ">>> Creating and starting VM '$INSTANCE'"
    limactl start --tty=false --name="$INSTANCE" "$RUNTIME_LIMA_YAML"
  fi
}

sandbox_seed_project() {
  if limactl shell "$INSTANCE" -- test -d "$GUEST_PROJECT_DIR/.git"; then
    echo ">>> Project already seeded in VM (run 'limactl factory-reset $INSTANCE' to refresh)"
    return
  fi

  echo ">>> Initializing bare repo in VM"
  limactl shell "$INSTANCE" -- git init --bare "$GUEST_PROJECT_DIR.git"

  echo ">>> Pushing project history into VM (branch: $HOST_BRANCH)"
  GIT_SSH_COMMAND="ssh -F $HOME/.lima/$INSTANCE/ssh.config" \
    git -C "$PROJECT_ROOT" push \
      "lima-$INSTANCE:$GUEST_PROJECT_DIR.git" \
      "HEAD:refs/heads/$HOST_BRANCH"

  echo ">>> Cloning working tree in VM"
  limactl shell "$INSTANCE" -- git clone "$GUEST_PROJECT_DIR.git" "$GUEST_PROJECT_DIR"
  limactl shell "$INSTANCE" -- bash -c "cd $GUEST_PROJECT_DIR && git checkout $HOST_BRANCH"
}

sandbox_ensure_remote() {
  local desired_url="lima-$INSTANCE:$GUEST_PROJECT_DIR"
  local current_url
  current_url="$(git -C "$PROJECT_ROOT" remote get-url sandbox-vm 2>/dev/null || true)"
  if [ -z "$current_url" ]; then
    echo ">>> Adding git remote 'sandbox-vm' -> $desired_url"
    git -C "$PROJECT_ROOT" remote add sandbox-vm "$desired_url"
  elif [ "$current_url" != "$desired_url" ]; then
    echo ">>> Updating git remote 'sandbox-vm' -> $desired_url"
    git -C "$PROJECT_ROOT" remote set-url sandbox-vm "$desired_url"
  fi
}

sandbox_pull_results() {
  echo ">>> Fetching commits from sandbox VM"
  GIT_SSH_COMMAND="ssh -F $HOME/.lima/$INSTANCE/ssh.config" \
    git -C "$PROJECT_ROOT" fetch sandbox-vm "$HOST_BRANCH"

  local ahead
  ahead="$(git -C "$PROJECT_ROOT" rev-list --count "HEAD..sandbox-vm/$HOST_BRANCH")"
  if [ "$ahead" = "0" ]; then
    echo ">>> No new commits from VM"
    return
  fi

  echo ">>> Fast-forwarding '$HOST_BRANCH' by $ahead commit(s)"
  if ! git -C "$PROJECT_ROOT" merge --ff-only "sandbox-vm/$HOST_BRANCH"; then
    echo "error: fast-forward failed — host has diverged from VM" >&2
    echo "       inspect: git log HEAD...sandbox-vm/$HOST_BRANCH" >&2
    return 1
  fi
}

sandbox_run_ralph() {
  echo ">>> Running $SANDBOX_RALPH_INNER_SCRIPT inside VM"
  limactl shell "$INSTANCE" -- \
    env "CLAUDE_CODE_OAUTH_TOKEN=$CLAUDE_CODE_OAUTH_TOKEN" \
    bash -lc "cd '$GUEST_PROJECT_DIR' && bash 'plugins/socrates/templates/$SANDBOX_RALPH_INNER_SCRIPT' $*"
}
