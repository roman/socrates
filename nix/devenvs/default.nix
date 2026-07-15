inputs:
{ pkgs, ... }:
{
  imports = [
    inputs.nixDir.devenvModules.nixdir-skill
  ];

  git-hooks.hooks = {
    nixfmt = {
      enable = true;
      package = pkgs.nixfmt-rfc-style;
    };
    shellcheck.enable = true;
  };

  claude.code.plugins = {
    nixDir.enable = true;
  };
}
