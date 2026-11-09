
{ pkgs }:

let
  theme = pkgs.writeTextDir "manifest.json" (builtins.toJSON {
    manifest_version = 3;
    name = "VSCodeDarkModern";
    version = "1.0";
    theme = {
      colors = {
        frame = [ 24 24 24 ];
        frame_inactive = [ 24 24 24 ];
        toolbar = [ 31 31 31 ];
        tab_text = [ 204 204 204 ];
        tab_background_text = [ 157 157 157 ];
        bookmark_text = [ 204 204 204 ];
        ntp_background = [ 31 31 31 ];
        ntp_text = [ 204 204 204 ];
        ntp_link = [ 77 170 252 ];
        omnibox_background = [ 24 24 24 ];
        omnibox_text = [ 204 204 204 ];
        toolbar_button_icon = [ 204 204 204 ];
      };
    };
  });
in
pkgs.chromium.override {
  enableWideVine = true;

  commandLineArgs = [
    "--ozone-platform=wayland"
    "--enable-features=NtpSimplificationBookmarkBar"
    "--load-extension=${theme}"
  ];
}
