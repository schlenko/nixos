{ pkgs }:

let
  theme = pkgs.writeTextDir "manifest.json" (builtins.toJSON {
    manifest_version = 3;
    name = "VSCodeDarkModern";
    version = "1.0";
    theme = {
      colors = {
        frame               = [ 24 24 24 ];     # #181818  tab strip
        frame_inactive      = [ 24 24 24 ];
        toolbar             = [ 31 31 31 ];     # #1F1F1F  active tab + toolbar
        tab_text            = [ 204 204 204 ];  # #CCCCCC
        tab_background_text = [ 157 157 157 ];  # #9D9D9D
        bookmark_text       = [ 204 204 204 ];
        ntp_background      = [ 31 31 31 ];     # #1F1F1F
        ntp_text            = [ 204 204 204 ];
        ntp_link            = [ 77 170 252 ];   # #4DAAFC
        omnibox_background  = [ 24 24 24 ];     # #313131
        omnibox_text        = [ 204 204 204 ];
        toolbar_button_icon = [ 204 204 204 ];
      };
    };
  });
in
pkgs.chromium.override {
  enableWideVine = true;

  commandLineArgs = [
    "--ozone-platform=wayland"
    "--load-extension=${theme}"
  ];
}