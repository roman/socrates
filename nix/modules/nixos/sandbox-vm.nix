inputs:
{ pkgs, lib, ... }:
{
  imports = [ "${inputs.nixos-lima}/lima.nix" ];

  environment.systemPackages = with pkgs; [
    claude-code
    jq
    gh
    ripgrep
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
