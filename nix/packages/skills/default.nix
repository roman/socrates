inputs:
{ stdenv, callPackage }:

stdenv.mkDerivation {
  name = "skills";
  pversion = "0.0.0";
  dontBuild = true;
  dontInstall = true;
  passthru = {
    socrates = callPackage (import ./socrates inputs) { };
  };
}
