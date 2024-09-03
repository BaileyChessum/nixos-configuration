# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let
  pypi2nix = import
    (pkgs.fetchgit {
      url = "https://github.com/nix-community/pypi2nix";
      # adjust rev and sha256 to desired version
      rev = "v2.0.1";
      sha256 = "sha256:0mxh3x8bck3axdfi9vh9mz1m3zvmzqkcgy6gxp8f9hhs6qg5146y";
    })
    { };
  rider = pkgs.callPackage ./rider.nix { };
  dotnetPkg =
    (with pkgs.dotnetCorePackages; combinePackages [
      sdk_6_0
    ]);
  godot4-mono = pkgs.callPackage ./godot { rider = rider.rider; dotnetPkg = dotnetPkg; };

  # Wayland overlay config
  waylandRev = "master";
  # rev = "1d3ef245cd7dd11abb16384133a1519c0128d42b";
  # rev = "50d9aedc5977e84367f5b14d68bf67ed2c6831df";
  # 'rev' could be a git rev, to pin the overla.
  # if you pin, you should use a tool like `niv` maybe, but please consider trying flakes
  waylandUrl = "https://github.com/nix-community/nixpkgs-wayland/archive/${waylandRev}.tar.gz";

  obsidian-fix = pkgs.callPackage ./obsidian { };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./nixfiles/nixos
    <home-manager/nixos>
  ];

  nix.settings.substituters = [
    "https://cuda-maintainers.cachix.org"
    "https://ros.cachix.org"
    "https://hyprland.cachix.org"
    "https://cache.nixos.org/"
    "https://nixpkgs-wayland.cachix.org"
    "https://hydra.novarover.space"
  ];

  nix.settings.trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo="
    "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    "nova-1:lRJ8YVtMKF5G7fk1OUx4vFyupTCwA4RrMNTX4JH7Hig="
  ];

  nixpkgs.overlays = [
    #(import ./nix-ros-overlay/overlay.nix)
    (import "${(builtins.fetchTarball waylandUrl)}/overlay.nix")
  ];
  nixpkgs.config.allowUnfree = true;

  # nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader = {
    systemd-boot.enable = true;
    efi = {
      canTouchEfiVariables = true;
      #efiSysMountPoint = "/boot/efi"; # ← use the same mount point here.
    };
    #grub = {
    #  enable = true;
    #  efiSupport = true;
    #  #efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
    #  device = "nodev";
    # useOSProber = true;
    #};
  };

  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "nodev";
  # boot.loader.grub.useOSProber = true;

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Australia/Melbourne";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    jack.enable = true;
  };
  hardware.pulseaudio.enable = lib.mkForce false;

  system.stateVersion = "23.05";
  home-manager.sharedModules = [{
    home.stateVersion = "23.05";
  }];

  # Nova config and user config
  nova.profile = "shared";
  nova.substituters.nova.password = import ./hydra-secret.nix;
  home-manager.users.nova = {
    home.packages = with pkgs; [
      slack
      brave
      obsidian
      zoom-us
      discord
      blackbox-terminal
      jetbrains.pycharm-professional
      jetbrains.webstorm
      rider.rider
      jetbrains.clion
      obs-studio
      prismlauncher

      # trying things out

      webcord-vencord
      discord-screenaudio
      lorien
      openboard

    ];

    # Adding to the task bar
    dconf.settings."org/gnome/shell".favorite-apps = [
      "brave-browser.desktop"
      "slack.desktop"
      "com.raggesilver.BlackBox.desktop"
      "obsidian.desktop"
    ];

    # Adds HiDPI scaling support
    dconf.settings."org/gnome/mutter".experimental-features = [
      "scale-monitor-framebuffer"
    ];

    programs.git = lib.mkForce {
      enable = true;
      userName = "Bailey Chessum";
      userEmail = "bailey.chessum1@gmail.com";
    };
  };
  home-manager.backupFileExtension = "backup";
  nova.desktop.browser.enable = lib.mkForce false;
  nova.workspace.enable = true;

  # TODO: kill
  environment.systemPackages = with pkgs; [
    # Utility
    gparted
    #gwe # GreenWithEnvy, for changing gpu fan curves
    #clinfo
    #nvtop-nvidia
    #virtualglLib
    #vulkan-loader
    #vulkan-tools
    #autorandr

    # obsidian --ozone-platform=x11
    pipewire
    reaper

    # Fun
    prismlauncher # Minecraft
    vital
    blender

    lmms
    bitwig-studio

    gimp
    gscreenshot
    shutter

    inkscape

    # ROS2
    #rosPackages.humble.rclpy
    #rosPackages.humble.geometry-msgs
    #rosPackages.humble.ros-base
    #rosPackages.humble.ros2cli
    # colcon

    # Logitech crap
    solaar
    logiops

    github-desktop

    # IDEs


    # Code
    # nodejs_21
    yarn

    pkgs.jdk21
    platformio
    platformio-core.udev
    openocd

    # Game Dev
    mono
    #godot4-mono
    dotnetPkg
    dotnetCorePackages.sdk_6_0
    #dotnetPackages.Nuget
    scons

    lunar-client

  ];

  services.udev.packages = [
    pkgs.platformio-core
    pkgs.openocd
  ];

  services.udev.extraRules = builtins.readFile ./udev-extra-rules.txt;

  # TODO: kill
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  # --- Wayland --- #
  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # for chromium/electron
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
      ];
    };
  };

  # -- Graphics card stuff --
  # https://nixos.wiki/wiki/Nvidia

  # Enable OpenGL
  hardware.graphics = {
    #enable = true;
    #driSupport = true;
    #driSupport32Bit = true;

    # Install additional packages that improve graphics performance and compatibility.
    # https://discourse.nixos.org/t/use-nvidia-drivers-only-to-silence-fans-and-intel-hd-gpu-otherwise/34724/5
    extraPackages = with pkgs; [
      amdvlk
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      libvdpau-va-gl
      nvidia-vaapi-driver
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      vulkan-validation-layers
    ];
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [
    "nvidia"
  ];

  # I apparently need this to get beta nvidia drivers to work? Putting in just in case lol
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    # package = config.boot.kernelPackages.nvidiaPackages.beta;

    # Stolen shamelessly from:
    # https://www.reddit.com/r/NixOS/comments/1cx9wsy/question_nvidia_555_beta_released_today/
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "555.58";

      sha256_64bit = "sha256-bXvcXkg2kQZuCNKRZM5QoTaTjF4l2TtrsKUvyicj5ew=";
      sha256_aarch64 = "sha256-lyYxDuGDTMdGxX3CaiWUh1IQuQlkI2hPEs5LI20vEVw=";
      openSha256 = "sha256-lyYxDuGDTMdGxX3CaiWUh1IQuQlkI2hPEs5LI20vEVw=";
      settingsSha256 = "sha256-vWnrXlBCb3K5uVkDFmJDVq51wrCoqgPF03lSjZOuU8M=";
      persistencedSha256 = "sha256-lyYxDuGDTMdGxX3CaiWUh1IQuQlkI2hPEs5LI20vEVw=";
    };

    # From https://discourse.nixos.org/t/use-nvidia-drivers-only-to-silence-fans-and-intel-hd-gpu-otherwise/34724/5
    nvidiaPersistenced = true;
  };

  # https://nixos.wiki/wiki/Nvidia#CUDA
  # https://discourse.nixos.org/t/solved-what-are-the-options-for-hardware-nvidia-package-docs-seem-out-of-date/14251/2

  # Service for starting up the GPU fans automatically
  systemd.services.gpu-fan = {
    enable = true;
    description = "GPU fan control";
    wantedBy = [ "multi-user.target" ];
    path = [ config.hardware.nvidia.package.settings ];
    script = ''nvidia-settings --ctrl-display=:1 -a [gpu:0]/GPUFanControlState=1 -a [fan:0]/GPUTargetFanSpeed=50 > /home/nova/fan.log'';
    serviceConfig.Type = "oneshot";
  };

  # -- USB and Logitech fixes --

  # Enable NixOS hardware for logitech (not sure this fixes anything)
  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };
}















