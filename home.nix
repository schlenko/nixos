{ config, lib, pkgs, pkgs-unstable, inputs, ... }:
let
  appsPath = ./Apps;

  wh = pkgs.callPackage (appsPath + "/Packages/wh.nix") { };
  bongocat-font = pkgs.callPackage (appsPath + "/Packages/bongocat-font.nix") { };
  looking-glass-client = pkgs.callPackage (appsPath + "/Packages/looking-glass-client.nix") { };
  rofi-wall = pkgs.callPackage (appsPath + "/Packages/rofi-wall.nix") { };
  waycal = pkgs.callPackage (appsPath + "/waybar/waycalender/waycal.nix") { };
  tui-globe = pkgs.callPackage(appsPath + "/Packages/tui-globe/tui-globe.nix") { }; 
  mako-tools = pkgs.callPackage (appsPath + "/mako/tools.nix") { };
   inherit (mako-tools) notify-sound battery-notify nixos-rebuild-notify;

  hyprtasking = inputs.hyprtasking.packages.${pkgs.stdenv.hostPlatform.system}.hyprtasking;

  hasPlugins = inputs ? hyprland-plugins;
in
{
  home.username = "t";
  home.homeDirectory = "/home/t";
  home.stateVersion = "25.11";

  fonts.fontconfig.enable = true;

  gtk = {
    enable = true;

    font = {
      name = "Chivo";
      size = 11;
    };
  };

  imports = [
    (appsPath + "/gtk-3.0/nemo.nix")
  ];

  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications."inode/directory" = "nemo.desktop";
  };

  dconf.settings = {
    "org/gnome/desktop/interface".color-scheme = "prefer-dark";

    "org/cinnamon/desktop/default-applications/terminal" = {
      exec = "kitty";
      exec-arg = "";
    };

    "org/nemo/preferences" = {
      show-image-thumbnails = "always";
      thumbnail-limit = lib.hm.gvariant.mkUint64 104857600; # 100 MB
      enable-delete = true;
    };
  };

  home.packages = [
    looking-glass-client
    wh
    tui-globe
    rofi-wall
    waycal
    notify-sound
    battery-notify
    nixos-rebuild-notify
    pkgs.mako
    pkgs.libnotify
    pkgs.awww
    pkgs.nerd-fonts.symbols-only
    bongocat-font
  ];

  # Battery notifications: event-driven script run as a user service
  systemd.user.services.battery-notify = {
    Unit = {
      Description = "Battery notifications";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${battery-notify}/bin/battery-notify";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  home.file.".config/hypr".source =
    appsPath + "/hypr";

  home.file.".config/kitty".source =
    appsPath + "/kitty";

  home.file.".config/rofi".source =
    appsPath + "/rofi";

  home.file.".config/waybar".source =
    appsPath + "/waybar";

  home.file.".config/gtk-3.0".source =
    appsPath + "/gtk-3.0";

  home.file.".local/share/wallpaper".source =
    appsPath + "/wallpaper";

  home.file.".local/share/fonts".source =
    appsPath + /font;

  home.file.".config/mako".source =
    appsPath + "/mako";

  home.file.".config/looking-glass".source =
    appsPath + /looking-glass;

  home.file.".zshrc".source =
    appsPath + /zsh/.zshrc;

  home.file.".oh-my-zsh/custom/themes".source =
    appsPath + /zsh/themes;

  home.file.".config/fastfetch".source =
    appsPath + "/fastfetch";
  
  home.file.".config/cava".source =
    appsPath + "/cava";

  home.file.".config/zsh/bongocat.zsh".source =
    appsPath + /zsh/bongocat.zsh;

  home.file.".local/share/hypr-plugins/libhyprtasking.so".source =
    "${hyprtasking}/lib/libhyprtasking.so";

  home.file.".local/share/hypr-plugins/libhyprbars.so".source =
    "${inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprbars}/lib/libhyprbars.so";

  programs.home-manager.enable = true;
}