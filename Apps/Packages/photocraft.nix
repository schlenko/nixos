{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pkg-config
    fontconfig
    freetype
    openssl

    wayland
    libxkbcommon
    libGL
    vulkan-loader
    libx11
    libxcursor
    libxi
    libxrandr
    libxcb
  ];
}