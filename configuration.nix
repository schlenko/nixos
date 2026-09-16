{ config, pkgs, ... }:

{

  imports = [
    ./hardware-configuration.nix
  ];

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";

  console.keyMap = "de";

  services.xserver.xkb = {
    layout = "de";
  };

  users.users.t = {
    isNormalUser = true;

    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  networking.networkmanager.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  security.polkit.enable = true;
  
  hardware.bluetooth.enable = true;


  systemd.user.services.polkit-gnome-agent = {
    description = "Polkit Authentication Agent";

    serviceConfig = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 2;
    };

    wantedBy = [ "default.target" ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.11";

  environment.systemPackages = with pkgs; [
    kitty
    adwaita-icon-theme
    quickshell
    hyprpaper
    hyprpicker

    (stdenvNoCC.mkDerivation {
      pname = "qylock-themes";
      version = "1.0";

      src = ./HyprlandApps/qylock/themes;

      installPhase = ''
        mkdir -p $out/share/sddm/themes
        cp -r ./* $out/share/sddm/themes/
      '';
    })

    git
    curl
    wget
    fastfetch
    python3
    bluetuith

    qt6.qtmultimedia
    qt6.qtbase
    qt6.qt5compat

    chromium
    zapzap
    telegram-desktop
    looking-glass-client
    spotify
    timeshift
    wl-clipboard
  ];
  
  environment.variables = {
    QML2_IMPORT_PATH = "/run/current-system/sw/lib/qt-6/qml";
    QML_IMPORT_PATH = "/run/current-system/sw/lib/qt-6/qml";
  };

  services.displayManager.sddm = {
    enable = true;
    theme = "pixel-night-city";

    wayland = {
      enable = true;
      compositor = "kwin";
    };

    extraPackages = with pkgs; [
      qt6.qtmultimedia
      qt6.qt5compat
    ];

    settings = {
      Theme = {
        CursorTheme = "Adwaita";
        CursorSize = 24;
      };
    };
  };

  programs.vscode = {
    enable = true;

    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      ms-python.python
    ];
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
}
