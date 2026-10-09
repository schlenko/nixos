{ pkgs, ... }:

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
      show-location-entry = true; 
        show-hidden-files = true;   # always show dotfiles
                 # editable path, no breadcrumbs

      # remove toolbar buttons
      show-icon-view-icon-toolbar = false;
      show-list-view-icon-toolbar = false;
      show-compact-view-icon-toolbar = false;
      show-search-icon-toolbar = false;
      show-edit-icon-toolbar = false;        # "toggle location entry" button
    };

    "org/nemo/window-state" = {
        start-with-menu-bar = false;
        side-pane-view = "places";   # always Places, never Tree
    };
    
  };
}