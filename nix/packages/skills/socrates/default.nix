_inputs:
{ lib, stdenv }:

stdenv.mkDerivation {
  pname = "skill-socrates";
  version = "0.1.0";

  src = ../../../../plugins/socrates;

  dontBuild = true;

  # socrates is a cohesive multi-skill plugin: the skills under skills/<name>/
  # cross-link the shared references/ via relative paths (../../references/...),
  # so the whole tree installs as one directory. The agent-skills module's
  # mkPluginDir sees the skills/ subdir and wraps it as an @skills-dir plugin
  # (socrates:spec, socrates:task, socrates:harvest, socrates:pm,
  # socrates:spec-format), preserving the bundled .claude-plugin/plugin.json.
  installPhase = ''
    runHook preInstall

    base=$out/share/agents/skills/socrates
    mkdir -p $base

    cp -r skills $base/
    cp -r references $base/

    # Task/overview templates the spec skill renders from (../../templates/...).
    cp -r templates $base/

    cp -r .claude-plugin $base/

    runHook postInstall
  '';

  meta = {
    description = "Socrates — structured design and autonomous development for Claude Code";
    platforms = lib.platforms.all;
  };
}
