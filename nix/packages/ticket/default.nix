_flakeInputs:
{
  stdenv,
  lib,
  fetchFromGitHub,
  makeWrapper,
  jq,
  ripgrep,
  coreutils,
  gnugrep,
  gnused,
  gawk,
  git,
}:

stdenv.mkDerivation rec {
  pname = "ticket";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "wedow";
    repo = "ticket";
    rev = "v${version}";
    hash = "sha256-orxqAwJBL+LHe+I9M+djYGa/yfvH67HdR/VVy8fdg90=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    install -m755 ticket $out/bin/tk

    wrapProgram $out/bin/tk \
      --prefix PATH : ${
        lib.makeBinPath [
          jq
          ripgrep
          coreutils
          gnugrep
          gnused
          gawk
          git
        ]
      }
  '';

  meta = {
    description = "Fast, git-native ticket tracking in a single bash script";
    homepage = "https://github.com/wedow/ticket";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
