{ config, pkgs, lib, ... }:

let
  # Change this to switch themes: "default" or "windows7"
  theme = "CatRice";

  themePath = ./Themes + "/${theme}";

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


  home.file.".config/hypr".source =
    themePath + "/hypr";

  home.file.".config/kitty".source =
    themePath + "/kitty";

  home.file.".config/rofi".source =
    themePath + "/rofi";

  home.file.".config/waybar".source =
    themePath + "/waybar";

  home.file.".config/gtk-3.0".source =
    themePath + "/gtk-3.0";

  home.file.".local/share/wallpaper".source =
    themePath + "/wallpaper";

   home.file.".local/share/fonts/Waycat.ttf".source =
    themePath + fonts/Waycat.ttf;
    


  home.file.".config/quickshell".source =
    ./Apps/quickshell;

  home.file.".config/qylock".source =
    ./Apps/qylock;

  home.file.".config/looking-glass".source =
    ./Apps/looking-glass;

  home.file.".zshrc".source =
    ./Apps/zsh/.zshrc;

  home.file.".oh-my-zsh/custom/themes".source =
    ./Apps/zsh/themes;

  programs.home-manager.enable = true;
}