{ config, lib, pkgs, pkgs-unstable, ... }:
let
  dotnet-combined =
    with pkgs-unstable.dotnetCorePackages;
    combinePackages [
      sdk_9_0
      sdk_10_0
    ];

  dotnet-wl-sync = pkgs.writeShellScript "dotnet-wl-sync" ''
    set -e
    target="$HOME/.local/share/dotnet-wl"
    stamp="$target/.nix-source"

    if [ ! -f "$stamp" ] || [ "$(cat "$stamp")" != "${dotnet-combined}" ]; then
      echo "dotnet: refreshing writable SDK copy..." >&2
      chmod -R u+w "$target" 2>/dev/null || true
      rm -rf "$target" and
      mkdir -p "$(dirname "$target")"
      cp -rL "${dotnet-combined}/share/dotnet" "$target"
      chmod -R u+w "$target"
      echo "${dotnet-combined}" > "$stamp"
    fi

    # Rider looks for its SDK in ~/.dotnet
    if [ -e "$HOME/.dotnet" ] && [ ! -L "$HOME/.dotnet" ]; then
      mv "$HOME/.dotnet" "$HOME/.dotnet.bak-$(date +%s)"
    fi
    ln -sfn "$target" "$HOME/.dotnet"
  '';

  dotnet-writable = pkgs.writeShellScriptBin "dotnet" ''
    ${dotnet-wl-sync}
    export DOTNET_ROOT="$HOME/.local/share/dotnet-wl"
    exec "$DOTNET_ROOT/dotnet" "$@"
  '';
in
{
  environment.systemPackages = [ dotnet-writable ];

  environment.sessionVariables = {
    DOTNET_ROOT = "/home/t/.local/share/dotnet-wl";
    DOTNET_ROOT_X64 = "/home/t/.local/share/dotnet-wl";
  };

  systemd.user.services.dotnet-wl-sync = {
    description = "Writable .NET SDK copy";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${dotnet-wl-sync}";
    };
    wantedBy = [ "default.target" ];
  };
}