{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "looking-glass-client";
  version = "236efcb155";

  src = pkgs.fetchgit {
    url = "https://github.com/gnif/LookingGlass.git";
    rev = "236efcb155f952f5d7d9fcd5891a3060ad254e68";
    fetchSubmodules = true;
    hash = "sha256-NAfV4Z0RZp2IGBzVAFysm53aGMEReT03RIN+45TveUU=";
  };

  nativeBuildInputs = with pkgs; [
    cmake
    pkg-config
    wayland-scanner
  ];

  buildInputs = with pkgs; [
    SDL2
    libGL
    libGLU
    libx11
    libxcb
    libxcursor
    libxi
    libxinerama
    libxrandr
    libxscrnsaver
    libxpresent
    libxkbcommon
    wayland
    wayland-protocols
    libdecor
    pipewire
    pulseaudio
    libsamplerate
    nettle
    gmp
    openssl
    fontconfig
    freetype
    libdrm
    libinput
    fuse3
    libunwind
    elfutils
    libffi
    spice-protocol
  ];

  dontUseCmakeConfigure = true;

  buildPhase = ''
    runHook preBuild

    cmake -S client -B client/build \
      -DCMAKE_BUILD_TYPE=Release \
      -DOPTIMIZE_FOR_NATIVE=OFF \
      -DENABLE_BACKTRACE=no

    cmake --build client/build -j$NIX_BUILD_CORES

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 \
      client/build/looking-glass-client \
      $out/bin/looking-glass-client

    runHook postInstall
  '';
}