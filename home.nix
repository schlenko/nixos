{ config, pkgs, lib, inputs, ... }:

let
  # Change this to switch themes
  theme = "CatRice";

  themePath = ./Themes + "/${theme}";

  wh = pkgs.callPackage ./Apps/Packages/wh.nix { };
  looking-glass-client = pkgs.callPackage ./Apps/Packages/looking-glass-client.nix { };
  rofi-wall = pkgs.callPackage ./Apps/Packages/rofi-wall.nix { };


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
    (themePath + "/gtk-3.0/nemo.nix")
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
      thumbnail-limit = lib.hm.gvariant.mkUint64 104857600;  # 100 MB
      enable-delete = true;
  };
};

  home.packages = [
    looking-glass-client
    rofi-wall
    wh
    pkgs.awww
    pkgs.nerd-fonts.symbols-only
  ];

  home.file.".config/hypr".source =
    themePath + "/hypr";

  home.file.".config/kitty".source =
    themePath + "/kitty";

  home.file.".config/rofi".source =
    themePath + "/rofi";

  home.file.".config/waybar".source =
    themePath + "/waybar";

  home.file.".config/gtk-3.0".source =
    themePath + "/gtk-3.0";

  home.file.".local/share/wallpaper".source =
    themePath + "/wallpaper";

  home.file.".local/share/fonts".source =
    themePath + /font;

  home.file.".config/looking-glass".source =
    ./Apps/looking-glass;

  home.file.".zshrc".source =
    ./Apps/zsh/.zshrc;

  home.file.".oh-my-zsh/custom/themes".source =
    ./Apps/zsh/themes;

  home.file.".local/share/hypr-plugins/libhyprtasking.so".source =
    "${hyprtasking}/lib/libhyprtasking.so";

    home.file.".local/share/hypr-plugins/libhyprbars.so".source =
  "${inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprbars}/lib/libhyprbars.so";


  programs.home-manager.enable = true;
}