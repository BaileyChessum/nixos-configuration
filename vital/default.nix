let
  pkgs = import <nixpkgs> { allowUnfree = true; };
in
{
  hello = pkgs.callPackage ./vital.nix { };
}