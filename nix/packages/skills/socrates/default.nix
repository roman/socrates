_inputs:
{ lib, stdenv }:

stdenv.mkDerivation {
  pname = "skill-socrates";
  version = "0.1.0";

  src = ../../../../plugins/socrates;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    base=$out/share/claude/skills/socrates
    mkdir -p $base

    # Commands
    cp -r commands $base/

    # Templates (spec/task templates for marketplace plugin)
    cp -r templates $base/

    # Voice and structure conventions (referenced by /spec)
    cp voice.md $base/

    # Skills (populated in later phases)
    if [ -d skills ] && [ "$(ls -A skills 2>/dev/null)" ]; then
      cp -r skills $base/
    fi

    # Plugin manifest
    mkdir -p $base/.claude-plugin
    cp .claude-plugin/plugin.json $base/.claude-plugin/

    runHook postInstall
  '';

  meta = {
    description = "Socrates — structured design for Claude Code";
    platforms = lib.platforms.all;
  };
}
