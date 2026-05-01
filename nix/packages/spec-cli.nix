_inputs:
{ pkgs, lib }:

pkgs.writeShellApplication {
  name = "spec";

  runtimeInputs = with pkgs; [ coreutils ];

  text = builtins.readFile ../../plugins/socrates/templates/spec;

  meta = {
    description = "Read-only CLI for Socrates spec/task status";
    platforms = lib.platforms.all;
  };
}
