
{ pkgs, lib, netextender-src }:

let
  client = pkgs.stdenvNoCC.mkDerivation {
    pname = "sonicwall-netextender-client";
    version = "10.2.850";

    src = netextender-src;
    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/opt/netExtenderClient"
      cp -a "$src/." "$out/opt/netExtenderClient/"
      chmod +x "$out/opt/netExtenderClient/netExtenderGui"

      runHook postInstall
    '';

    meta = {
      description = "SonicWall NetExtender VPN client";
      homepage = "https://www.sonicwall.com/products/remote-access/vpn-clients/";
      license = lib.licenses.unfree;
      platforms = [ "x86_64-linux" ];
    };
  };

  launch = pkgs.writeShellScript "netextender-gui" ''
    cd "${client}/opt/netExtenderClient"
    exec ./netExtenderGui "$@"
  '';

in
pkgs.buildFHSEnv {
  name = "netextender";
  chdirTo = "/";

  targetPkgs = p: with p; [
    bash
    coreutils
    glibc
    zlib
    stdenv.cc.cc.lib
    openssl
    libX11
    libXext
    libXrender
    libXtst
    libXi
    libXrandr
    libXcursor
    libXinerama
    libxcb
    fontconfig
    freetype
    gtk3
    alsa-lib
    openjdk
    ppp
    iproute2
    iputils
  ];

  extraInstallCommands = ''
    mkdir -p "$out/usr/lib64"
    ln -sf "${client}/opt/netExtenderClient/NetExtender.jar" \
      "$out/usr/lib64/NetExtender.jar"
  '';

  runScript = "${launch}";
}
