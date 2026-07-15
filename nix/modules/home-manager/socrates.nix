inputs:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.claude-code.plugins.socrates;
in
{
  options.programs.claude-code.plugins.socrates = {
    enable = lib.mkEnableOption "socrates skill plugin for Claude Code";

    package = lib.mkOption {
      type = lib.types.package;
      default = inputs.self.packages.${pkgs.system}.skills.socrates;
      defaultText = lib.literalExpression "inputs.self.packages.\${pkgs.system}.skills.socrates";
      description = "The socrates skill package to use.";
    };
  };

  config = lib.mkMerge [
    {
      programs.agentSkills.socrates.package = lib.mkDefault cfg.package;
    }

    (lib.mkIf cfg.enable {
      # Cohesive multi-skill plugin: the agent-skills module wraps the skills/
      # subtree as an @skills-dir plugin, exposing socrates:spec, socrates:task,
      # socrates:harvest, socrates:pm, and socrates:spec-format.
      programs.agentSkills.socrates.vendors.claude.enable = true;

      assertions = [
        {
          assertion = cfg.package != null;
          message = "socrates package must be provided when enabled";
        }
      ];
    })
  ];
}
