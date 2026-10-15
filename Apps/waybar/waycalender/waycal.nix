
{ lib
, rustPlatform
, pkg-config
, gtk4
, gtk4-layer-shell
, wayland
}:

rustPlatform.buildRustPackage {
  pname = "waycal";
  version = "0.1.0";

  src = ./waycal;

  cargoHash = "sha256-brC1igJxiX5JB0BfpZqpQf88JEZFfQcGnWtW3QElrvE=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    gtk4
    gtk4-layer-shell
    wayland
  ];

  meta = {
    description = "A lightweight calendar popup for Waybar";
    homepage = "https://github.com/ForrestKnight/waycal";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
