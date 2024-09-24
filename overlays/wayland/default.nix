

let 
  # Wayland overlay config
  waylandRev = "master";
  # rev = "1d3ef245cd7dd11abb16384133a1519c0128d42b";
  # rev = "50d9aedc5977e84367f5b14d68bf67ed2c6831df";
  # 'rev' could be a git rev, to pin the overla.
  # if you pin, you should use a tool like `niv` maybe, but please consider trying flakes
  waylandUrl = "https://github.com/nix-community/nixpkgs-wayland/archive/${waylandRev}.tar.gz";

  wayland = builtins.fetchTarball waylandUrl;
in
  import "${wayland}/overlay.nix"