{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "awtwall";
  version = "local";

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm755 ${./awtwall} $out/bin/awtwall
    patchShebangs $out/bin/awtwall
    wrapProgram $out/bin/awtwall \
      --prefix PATH : ${pkgs.lib.makeBinPath (with pkgs; [
        imagemagick
        chafa
        libsixel
        jq
        ffmpeg
        xdg-utils
        curl
        swww
      ])}

    runHook postInstall
  '';
}