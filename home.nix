{ config, pkgs, ... }:

{
  home.username = "t";
  home.homeDirectory = "/home/t";

  home.stateVersion = "25.11";

    dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  home.activation.installHyprlandConfig =
    config.lib.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/.config/hypr"

      cp -r ${./Apps/hypr}/. "$HOME/.config/hypr/"

      chmod 644 "$HOME/.config/hypr/hyprland.conf"
    '';

    home.file.".config/kitty".source =
    ./Apps/kitty;

    home.file.".config/quickshell".source =
    ./Apps/quickshell;    

   home.file.".config/qylock".source =
    ./Apps/qylock;

       home.file.".config/looking-glass".source =
    ./Apps/looking-glass;

  home.file.".config/gtk-3.0/settings.ini".source =
   ./Apps/gtk-3.0/settings.ini;

    home.file.".zshrc".source =
     ./Apps/zsh/.zshrc;

  programs.home-manager.enable = true;
}