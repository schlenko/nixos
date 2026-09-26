{ config, pkgs, ... }:

let
  looking-glass-client = pkgs.stdenv.mkDerivation {
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
      wayland-scanner   # the actual tool/pkg-config file CMake needs
    ];

    buildInputs = with pkgs; [
      SDL2
      libGL
      libGLU
      libX11
      libxcb
      libXcursor
      libXi
      libXinerama
      libXrandr
      libXScrnSaver
      libXpresent
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
      libXpresent
      libffi
      libdecor
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

      cmake --build client/build -j2

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      install -Dm755 \
        client/build/looking-glass-client \
        $out/bin/looking-glass-client

      runHook postInstall
    '';
  };
in
{
  home.username = "t";
  home.homeDirectory = "/home/t";
  home.stateVersion = "25.11";

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  home.packages = [
    looking-glass-client
  ];

  home.activation.installHyprlandConfig =
    config.lib.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/.config/hypr"
      cp -r ${./Apps/hypr}/. "$HOME/.config/hypr/"
      chmod 644 "$HOME/.config/hypr/hyprland.conf"
    '';

  home.file.".config/kitty".source =
    ./Apps/kitty;

  home.file.".config/quickshell".source =
    ./Apps/quickshell;

  home.file.".config/qylock".source =
    ./Apps/qylock;

  home.file.".config/looking-glass".source =
    ./Apps/looking-glass;

  home.file.".config/gtk-3.0/settings.ini".source =
    ./Apps/gtk-3.0/settings.ini;

  home.file.".zshrc".source =
    ./Apps/zsh/.zshrc;

  home.file.".config/btop".source =
    ./Apps/btop;


  programs.home-manager.enable = true;
}