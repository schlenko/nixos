{ config, lib, pkgs, pkgs-unstable, inputs, ... }:
let
  appsPath = ./Apps;
  link = path: config.lib.file.mkOutOfStoreSymlink "/etc/nixos/Apps/${path}";

  wh = pkgs.callPackage (appsPath + "/Packages/wh.nix") { };
  latto = pkgs.callPackage (appsPath + "/latto/latto.nix") {src = appsPath + "/latto"; };
  looking-glass-client = pkgs.callPackage (appsPath + "/Packages/looking-glass-client.nix") { };
  rofi-wall = pkgs.callPackage (appsPath + "/Packages/rofi-wall.nix") { };
  tui-globe = pkgs.callPackage(appsPath + "/Packages/tui-globe/tui-globe.nix") { }; 
  mako-tools = pkgs.callPackage (appsPath + "/mako/tools.nix") { };
   inherit (mako-tools) notify-sound battery-notify nixos-rebuild-notify usb-notify;

  hyprtasking = inputs.hyprtasking.packages.${pkgs.stdenv.hostPlatform.system}.hyprtasking;

  hasPlugins = inputs ? hyprland-plugins;
in
{
  home.username = "t";
  home.homeDirectory = "/home/t";
  home.stateVersion = "25.11";

  fonts.fontconfig.enable = true;

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
    latto 

    notify-sound
    battery-notify
    usb-notify
    nixos-rebuild-notify

    pkgs.mako
    pkgs.libnotify
    pkgs.awww
    pkgs.nerd-fonts.symbols-only
  ];

  # Battery notifications: event-driven script run as a user service
    systemd.user.services.usb-notify = {
    Unit = {
      Description = "USB / USB-C plug notifications";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${usb-notify}/bin/usb-notify usb";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.mount-notify = {
    Unit = {
      Description = "Mount / unmount notifications";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${usb-notify}/bin/usb-notify mount";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  home.file.".config/hypr".source = link "hypr";
  home.file.".config/kitty".source = link "kitty";
  home.file.".config/rofi".source = link "rofi";
  home.file.".config/waybar".source = link "waybar";
  home.file.".config/gtk-3.0".source = link "gtk-3.0";
  home.file.".local/share/wallpaper".source = link "wallpaper";
  home.file.".local/share/fonts".source = link "font";
  home.file.".config/mako".source = link "mako";
  home.file.".config/looking-glass".source = link "looking-glass";
  home.file.".config/fastfetch".source = link "fastfetch";
  home.file.".config/cava".source = link "cava";
  home.file.".config/latto/config.json".source = link "latto/config.json";

  home.file.".zshrc".source = link "zsh/.zshrc";
  home.file.".oh-my-zsh/custom/themes".source = link "zsh/themes";
  home.file.".config/zsh/bongocat.zsh".source = link "zsh/bongocat.zsh";

  home.file.".local/share/hypr-plugins/libhyprtasking.so".source =
    "${hyprtasking}/lib/libhyprtasking.so";

  home.file.".local/share/hypr-plugins/libhyprbars.so".source =
    "${inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprbars}/lib/libhyprbars.so";

  programs.home-manager.enable = true;
}