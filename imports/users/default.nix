{ ... }:

{
  users.users.bailey.isNormalUser = true;
  home-manager.users.bailey = import ./bailey.nix;
}