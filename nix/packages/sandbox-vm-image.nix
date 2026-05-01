inputs:
{ pkgs, lib }:
# TODO: nixos-generators is deprecated as of NixOS 25.05 in favour of
# `image.modules.<name>` + `config.system.build.image` (nixos/modules/image/).
# Migrate when nixos-lima migrates upstream — switching unilaterally requires
# resolving a bootloader merge between disk-image.nix (systemd-boot) and
# nixos-lima/lima.nix (grub-efi).
let
  guestPkgs = import inputs.nixpkgs {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "claude-code"
      ];
  };
  img = inputs.nixos-generators.nixosGenerate {
    pkgs = guestPkgs;
    format = "qcow-efi";
    specialArgs = { inherit inputs; };
    modules = [
      (import ../modules/nixos/sandbox-vm.nix inputs)
    ];
  };
in
lib.addMetaAttrs {
  description = "qcow2 NixOS image for the Socrates sandbox VM";
  platforms = lib.platforms.linux;
} img
