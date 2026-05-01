{
  description = "Socrates — structured design and autonomous development for Claude Code";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nixDir.url = "github:roman/nixDir/v3";
    nixDir.inputs.nixpkgs.follows = "nixpkgs";
    nixDir.inputs.devenv.follows = "devenv";

    devenv.url = "github:cachix/devenv/v2.0.6";

    systems.url = "github:nix-systems/default";

    nixos-lima.url = "github:nixos-lima/nixos-lima/v0.0.5";
    nixos-lima.inputs.nixpkgs.follows = "nixpkgs";

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = [
        inputs.devenv.flakeModule
        inputs.nixDir.flakeModule
      ];

      nixDir = {
        enable = true;
        root = ./.;
        importWithInputs = true;
      };
    };
}
