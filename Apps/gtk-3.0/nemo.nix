{ pkgs, ... }:

let
  toggleHidden = pkgs.writeShellScript "nemo-toggle-hidden" ''
    key="org.nemo.preferences show-hidden-files"
    if [ "$(${pkgs.glib}/bin/gsettings get $key)" = "true" ]; then
      ${pkgs.glib}/bin/gsettings set $key false
    else
      ${pkgs.glib}/bin/gsettings set $key true
    fi
  '';
in
{
  home.packages = [ pkgs.nemo-with-extensions ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications."inode/directory" = "nemo.desktop";
  };

  dconf.settings = {
    "org/cinnamon/desktop/applications/terminal" = {
      exec = "kitty";
    };

    "org/nemo/preferences" = {
      default-folder-viewer = "list-view";   # always list view
      show-location-entry = true;            # editable path, no breadcrumbs
      show-hidden-files = true;              # start with dotfiles visible

      # remove toolbar buttons
      show-compact-view-icon-toolbar = false;
      show-search-icon-toolbar = false;
      show-edit-icon-toolbar = false;        # "toggle location entry" button
    };

    "org/nemo/window-state" = {
      start-with-menu-bar = false;           # hides File / Edit / View...
      side-pane-view = "places";             # always Places, never Tree
    };
  };

  # right-click on empty space in a folder -> "Toggle Hidden Files"
  home.file.".local/share/nemo/actions/toggle-hidden.nemo_action".text = ''
    [Nemo Action]
    Name=Toggle Hidden Files
    Comment=Show or hide dotfiles
    Exec=${toggleHidden}
    Icon-Name=view-reveal-symbolic
    Selection=none
    Extensions=any;
  '';
}