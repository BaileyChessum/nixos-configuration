{ pkgs, electron, makeDesktopItem, fetchurl, ... }:

# https://www.reddit.com/r/NixOS/comments/1ckgfxk/add_startup_command_line_arguments_to_programs/
pkgs.obsidian.overrideAttrs (e: rec {
  # Add arguments to the .desktop entry
  desktopItem = e.desktopItem.override (d: {
    exec = ''
      ${d.exec} --ozone-platform=x11 --enable-wayland-ime
    '';
  });

  # Update the install script to use the new .desktop entry
  installPhase = builtins.replaceStrings [ "${e.desktopItem}" ] [ "${desktopItem}" ] e.installPhase;
})
