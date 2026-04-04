inputs:
{ pkgs, ... }:

{
  imports = [
    inputs.nixDir.devenvModules.nixdir-skill
  ];

  packages = [
    inputs.self.packages.${pkgs.system}.ticket
    pkgs.jq
  ];

  git-hooks.hooks.nixfmt = {
    enable = true;
    package = pkgs.nixfmt-rfc-style;
  };

  claude.code.plugins.nixDir.enable = true;
}
