inputs:
{ pkgs, lib, ... }:
{
  imports = [ "${inputs.nixos-lima}/lima.nix" ];

  environment.systemPackages = with pkgs; [
    claude-code
    jq
    gh
    ripgrep
    inputs.self.packages.${pkgs.system}.ticket
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
