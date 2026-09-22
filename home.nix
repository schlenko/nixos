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

      cp -r ${./HyprlandApps/hypr}/. "$HOME/.config/hypr/"

      chmod 644 "$HOME/.config/hypr/hyprland.conf"
    '';

    home.file.".config/kitty".source =
    ./HyprlandApps/kitty;

    home.file.".config/quickshell".source =
    ./HyprlandApps/quickshell;    

   home.file.".config/qylock".source =
    ./HyprlandApps/qylock;

       home.file.".config/looking-glass".source =
    ./looking-glass;

    

  programs.home-manager.enable = true;
}