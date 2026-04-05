inputs:
{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.claude.code.plugins.socrates;
  defaultPackage = inputs.self.packages.${pkgs.system}.skills.socrates;

  pluginDir = "${cfg.package}/share/claude/skills/socrates";

  mkCommandFiles =
    pkg:
    let
      cmdDir = "${pluginDir}/commands";
      cmdFiles = builtins.filter (f: lib.hasSuffix ".md" f) (
        builtins.attrNames (builtins.readDir cmdDir)
      );
    in
    lib.listToAttrs (
      map (fname: {
        name = ".claude/commands/socrates-${lib.removeSuffix ".md" fname}.md";
        value.text = builtins.readFile "${cmdDir}/${fname}";
      }) cmdFiles
    );

  mkSkillFiles =
    pkg:
    let
      skillsDir = "${pluginDir}/skills";
      hasSkills = builtins.pathExists skillsDir;
      skillEntries = if hasSkills then builtins.attrNames (builtins.readDir skillsDir) else [ ];
      isDir = name: (builtins.readDir skillsDir).${name} == "directory";
      skillDirs = builtins.filter isDir skillEntries;
    in
    lib.listToAttrs (
      builtins.concatMap (
        skillName:
        let
          dir = "${skillsDir}/${skillName}";
          skillFiles = builtins.attrNames (builtins.readDir dir);
        in
        map (fname: {
          name = ".claude/skills/socrates-${skillName}/${fname}";
          value.text = builtins.readFile "${dir}/${fname}";
        }) skillFiles
      ) skillDirs
    );
in
{
  options.claude.code.plugins.socrates = {
    enable = lib.mkEnableOption "Socrates plugin for Claude Code";

    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPackage;
      defaultText = lib.literalExpression "inputs.self.packages.\${pkgs.system}.skills.socrates";
      description = "The Socrates plugin package to use.";
    };

    templates = {
      install = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Install shell script templates (ralph.sh, ralph-once.sh, ralph-format.sh)
          into the project root. When false, /init copies them manually.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    packages = [
      inputs.self.packages.${pkgs.system}.ticket
      pkgs.jq
    ];

    files =
      mkCommandFiles cfg.package
      // (lib.optionalAttrs (builtins.pathExists "${pluginDir}/skills") (mkSkillFiles cfg.package))
      // lib.optionalAttrs cfg.templates.install {
        "ralph.sh" = {
          text = builtins.readFile "${pluginDir}/templates/ralph.sh";
          executable = true;
        };
        "ralph-once.sh" = {
          text = builtins.readFile "${pluginDir}/templates/ralph-once.sh";
          executable = true;
        };
        "ralph-format.sh" = {
          text = builtins.readFile "${pluginDir}/templates/ralph-format.sh";
          executable = true;
        };
      };

    env.SOCRATES_TEMPLATES = "${pluginDir}/templates";
  };
}
