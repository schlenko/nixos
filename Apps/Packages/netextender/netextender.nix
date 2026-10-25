{ pkgs, netextender-src }:

let
  src = netextender-src;

  payload = pkgs.runCommand "netextender-payload" { } ''
    mkdir -p $out/lib $out/bin

    # everything from the tarball -> /lib (visible as /usr/lib and /usr/lib64:
    # jar, .so files, certs, sslvpn, ...)
    cp -r ${src}/. $out/lib/
    chmod -R u+w $out/lib

    # executables also on PATH
    for f in netExtender netExtenderGui nxMonitor sslvpn; do
      install -Dm755 ${src}/$f $out/bin/$f
    done
  '';

  run = pkgs.writeShellScript "netextender-run" ''
    export LD_LIBRARY_PATH=/usr/lib64''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
    [ -n "$NX_SHELL" ] && exec bash
    if [ $# -eq 0 ]; then
      exec /usr/bin/netExtenderGui
    else
      exec /usr/bin/netExtender "$@"
    fi
  '';
in
pkgs.buildFHSEnv {
  name = "netextender";

  targetPkgs = p: [
    payload
    p.jre
    p.ppp
    p.iproute2
    p.iptables
    p.procps
    p.coreutils
    p.gnugrep
    p.gnused
    p.gawk
    p.bash
    p.openssl
    p.zlib
    p.gtk3
    p.xorg.libX11
    p.xorg.libXtst
    p.xorg.libXrender
  ];

  extraBwrapArgs = [
    "--bind-try /etc/nixos /etc/nixos"
    "--bind-try /etc/ppp /etc/ppp"
  ];

  runScript = "${run}";
}