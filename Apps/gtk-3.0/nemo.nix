{ pkgs, lib, ... }:

let
  toggleHidden = pkgs.writeShellScript "nemo-toggle-hidden" ''
    key="org.nemo.preferences show-hidden-files"
    if [ "$(${pkgs.glib}/bin/gsettings get $key)" = "true" ]; then
      ${pkgs.glib}/bin/gsettings set $key false
    else
      ${pkgs.glib}/bin/gsettings set $key true
    fi
  '';

  # Shows everything ExifTool and MediaInfo know about the selected file
  showFullInfo = pkgs.writeShellScript "nemo-full-info" ''
    f="$1"
    {
      echo "==== ExifTool ===="
      ${pkgs.exiftool}/bin/exiftool "$f"
      echo
      echo "==== MediaInfo ===="
      ${pkgs.mediainfo}/bin/mediainfo "$f"
    } | ${pkgs.less}/bin/less -R
  '';

  gstPlugins = with pkgs.gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
  ];
in
{
  home.packages = with pkgs; [
    nemo-with-extensions

    # Metadata tools (used by the right-click action)
    exiftool
    mediainfo
    ffmpeg          # provides ffprobe

    # Codec support so Nemo can read video/audio info
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
  ];

  # Let GStreamer find its plugins (Nix has no global plugin path)
  home.sessionVariables = {
    GST_PLUGIN_SYSTEM_PATH_1_0 =
      lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" gstPlugins;
  };

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

  # right-click on a file -> "Show Full Metadata"
  home.file.".local/share/nemo/actions/full-info.nemo_action".text = ''
    [Nemo Action]
    Name=Show Full Metadata
    Comment=All metadata via ExifTool and MediaInfo
    Exec=kitty --hold ${showFullInfo} "%F"
    Icon-Name=document-properties
    Selection=s
    Extensions=any;
  '';
}