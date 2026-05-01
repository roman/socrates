inputs:
{ pkgs, lib }:
let
  pkgs-unstable = import inputs.nixos-lima.inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
  };
  lima = pkgs-unstable.lima.override {
    withAdditionalGuestAgents = true;
    qemu = pkgs.qemu;
  };
in
pkgs.writeShellApplication {
  name = "sandbox-ralph";

  runtimeInputs = [
    lima
    pkgs.qemu
    pkgs.git
    pkgs.openssh
  ];

  text = ''
    export SANDBOX_LIMA_YAML='${./lima.yaml}'
    export SANDBOX_RALPH_INNER_SCRIPT='ralph.sh'

    ${builtins.readFile ./sandbox-vm-lib.sh}

    sandbox_main "$@"
  '';

  meta = {
    description = "Run Socrates Ralph autonomously inside a sandbox VM";
    platforms = lib.platforms.linux;
  };
}
