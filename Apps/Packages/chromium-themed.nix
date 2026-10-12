{ pkgs }:

let
  theme = pkgs.writeTextDir "manifest.json" (builtins.toJSON {
    manifest_version = 3;
    name = "CatRice";
    version = "1.0";
    theme = {
      colors = {
        frame               = [ 13 13 18 ];
        frame_inactive      = [ 13 13 18 ];
        toolbar             = [ 17 17 22 ];
        tab_text            = [ 196 167 231 ];
        tab_background_text = [ 91 73 80 ];
        bookmark_text       = [ 196 167 231 ];
        ntp_background      = [ 0 0 0 ];
        ntp_text            = [ 196 167 231 ];
        ntp_link            = [ 196 167 231 ];
        button_background   = [ 0 0 0 0 ];
        omnibox_background  = [ 0 0 0 ];
        omnibox_text        = [ 196 167 231 ];
        toolbar_button_icon = [ 196 167 231 ];
        frame_overlay       = [ 63 63 66 ];
      };
      tints.buttons = [ 0.75 0.4 0.8 ];
    };
  });
in
pkgs.chromium.override {
  commandLineArgs = [
    "--ozone-platform=wayland"
    "--load-extension=${theme}"
  ];
}
