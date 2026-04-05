inputs:
{ pkgs, ... }:

{
  imports = [
    inputs.nixDir.devenvModules.nixdir-skill
    (import ../modules/devenv/socrates.nix inputs)
  ];

  git-hooks.hooks.nixfmt = {
    enable = true;
    package = pkgs.nixfmt-rfc-style;
  };

  claude.code.plugins.nixDir.enable = true;
  claude.code.plugins.socrates.enable = true;
}
