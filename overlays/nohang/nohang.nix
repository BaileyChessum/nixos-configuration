{
  pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, ...
}:

pkgs.stdenv.mkDerivation {
  name = "nohang";

  src = pkgs.fetchFromGitHub {
    owner = "hakavlad";
    repo = "nohang";
    rev = "master";
    hash = "sha256-gCGjQoSxY/MprrcpdFrJ4VrsNyruqsUSPrHoy+R07Io=";
  };

  meta = {
    description = "A sophisticated low memory handler for Linux";
    longDescription = ''
      a highly configurable daemon for Linux which is able to correctly prevent 
      out of memory (OOM) and keep system responsiveness in low memory conditions.
    '';
    homepage = "https://www.gnu.org/software/hello/manual/";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

  nativeBuildInputs = with pkgs; [
    pandoc
    
  ];

  buildInputs = [
    pkgs.man
  ];



}