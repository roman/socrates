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

    # Templates (shell scripts + spec/task templates)
    cp -r templates $base/

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
    description = "Socrates — structured design and autonomous development for Claude Code";
    platforms = lib.platforms.all;
  };
}
