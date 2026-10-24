
{ lib, rustPlatform, pkg-config }:

rustPlatform.buildRustPackage {
  pname = "tui-globe";
  version = "0.3.0";

  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [
    pkg-config
  ];

  meta = {
    description = "Terminal globe TUI";
    platforms = lib.platforms.linux;
  };
}
