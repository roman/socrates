# Sandbox VM — Operator Guide

Runs the Ralph loop inside a Lima/QEMU VM so `--dangerously-skip-permissions`
can't touch the host. The VM has no filesystem mounts; the host's `$HOME`
is completely invisible to the agent. Project state is exchanged over git.

## One-time setup

**1. Get an OAuth token for headless Claude use:**

```bash
claude setup-token        # opens browser once; prints CLAUDE_CODE_OAUTH_TOKEN
```

Store the token (password manager, agenix, or shell profile):

```bash
export CLAUDE_CODE_OAUTH_TOKEN=<value>   # add to ~/.bashrc / ~/.zshrc
```

The token is valid for one year. If revoked: `claude logout && claude setup-token`.

## Running the sandbox

```bash
# Autonomous loop — runs until no work remains or max iterations reached
nix run .#sandbox-ralph

# Autonomous single iteration — same as the loop but exits after one cycle
nix run .#sandbox-ralph-once
```

**First run** builds the VM image (~5–15 min depending on cache), boots the VM
(~50s), and seeds the project into the VM via git. Subsequent runs skip all
of that and go straight to running Ralph.

`CLAUDE_CODE_OAUTH_TOKEN` must be exported before running.

### Commit author identity

Ralph's commits inside the VM are attributed using (in order):

1. `GIT_AUTHOR_NAME` / `GIT_AUTHOR_EMAIL` if exported on the host
2. Otherwise the host's `git config user.name` / `user.email`

Committer defaults to author. Override with `GIT_COMMITTER_NAME` /
`GIT_COMMITTER_EMAIL` if you want them to differ. The script refuses to
start if no author identity can be resolved.

## Reviewing Ralph's commits

The wrapper script ends each run by fetching `sandbox-vm/<branch>` and
fast-forwarding the host branch. The `sandbox-vm` git remote is auto-added
the first time it runs. Preconditions enforced before the VM boots:

- Host must be on a branch (not detached HEAD)
- Host worktree must have no uncommitted tracked changes

If the host branch has diverged from the VM (e.g. you committed locally
during the run), fast-forward fails and the script prints:

```
error: fast-forward failed — host has diverged from VM
       inspect: git log HEAD...sandbox-vm/<branch>
```

Recover by merging or cherry-picking manually. To inspect manually at any
time:

```bash
GIT_SSH_COMMAND="ssh -F ~/.lima/sandbox-vm/ssh.config" git fetch sandbox-vm
git log HEAD..sandbox-vm/<branch>
```

## VM lifecycle

| Command | Effect |
|---------|--------|
| `nix run .#sandbox-ralph` | Boot if needed + run loop |
| `limactl stop sandbox-vm` | Graceful shutdown; disk state preserved |
| `limactl start sandbox-vm` | Resume from stopped state |
| `limactl shell sandbox-vm` | Interactive shell into the VM |
| `limactl factory-reset sandbox-vm` | Nuke VM disk; recreate from qcow2 |
| `limactl delete sandbox-vm` | Remove instance entirely |

`limactl` must be in PATH — either installed on the host or via
`nix develop github:nixos-lima/nixos-lima`.

**After factory-reset**: re-run `nix run .#sandbox-ralph-once` — it detects
the missing project clone and re-seeds from the host.

## Customising the guest

Guest packages are declared in `nix/modules/nixos/sandbox-vm.nix`
(`environment.systemPackages`). The VM image is rebuilt with:

```bash
nix build .#sandbox-vm-image
limactl factory-reset sandbox-vm   # pick up the new image
```

## macOS (prerequisites)

Building the qcow2 requires a Linux builder. Confirmed path:
`nix-darwin`'s `linux-builder` or `cpick/nix-rosetta-builder`.

> **Note**: x86_64 macOS image builds are an open nixos-lima issue (#9).
> aarch64 (Apple Silicon) with linux-builder is the paved path.

## Troubleshooting

**"Not logged in"** — `CLAUDE_CODE_OAUTH_TOKEN` is not exported in the
calling shell. The token is injected at `limactl shell` invocation time;
it never persists to the VM's disk.

**VM stuck on "Waiting for containerd"** — only affects instances created
before `containerd: { system: false, user: false }` was added to
`lima.yaml`. Delete the instance and recreate:
```bash
limactl delete sandbox-vm && nix run .#sandbox-ralph-once
```

**"No such file or directory" for `/home/roman/...`** — expected. The host
home is not mounted. The guest project lives at `/home/<user>.linux/socrates`.

**Git push fails on first seed** — Lima's SSH host alias is `lima-sandbox-vm`
(not `sandbox-vm`). The sandbox-vm-lib.sh script handles this internally;
ad-hoc git commands against the VM need the same alias.
