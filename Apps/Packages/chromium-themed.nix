{ pkgs }:

let
  vscodeTheme = pkgs.writeTextDir "manifest.json" (builtins.toJSON {
    manifest_version = 3;
    name = "VSCode Dark Modern";
    version = "1.0";
    theme = {
      colors = {
        frame               = [ 24 24 24 ];
        frame_inactive      = [ 24 24 24 ];
        toolbar             = [ 31 31 31 ];
        tab_text            = [ 204 204 204 ];
        tab_background_text = [ 157 157 157 ];
        bookmark_text       = [ 204 204 204 ];
        toolbar_button_icon = [ 157 157 157 ];
        omnibox_background  = [ 49 49 49 ];
        omnibox_text        = [ 204 204 204 ];
        ntp_background      = [ 31 31 31 ];
        ntp_text            = [ 204 204 204 ];
        ntp_link            = [ 0 120 212 ];
      };
    };
  });
in
pkgs.chromium.override {
  commandLineArgs = [
    "--ozone-platform=wayland"
    "--disable-features=DisableLoadExtensionCommandLineSwitch"
    "--load-extension=${vscodeTheme}"
  ];
}