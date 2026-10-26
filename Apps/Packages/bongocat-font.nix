{ pkgs }:

pkgs.runCommand "bongocat-font"
  {
    nativeBuildInputs = [ pkgs.fontforge pkgs.imagemagick pkgs.potrace ];
    src = ../zsh/bongocat;
  }
  ''
    export HOME=$TMPDIR
    mkdir -p $out/share/fonts/truetype traced

    for n in idle left right; do
      # lowest alpha value in the image (0 = has transparent pixels)
      amin=$(magick $src/$n.png -alpha extract -format '%[fx:int(minima*100)]' info:)

      if [ "$amin" -lt 90 ]; then
        # transparent background: use the alpha channel as the shape
        # (opaque -> black, because potrace traces black)
        magick $src/$n.png -alpha extract -negate -threshold 50% \
          -type bilevel traced/$n.pbm
      else
        # opaque background: old brightness logic
        lum=$(magick $src/$n.png -colorspace Gray \
          -crop 1x1+0+0 +repage -format '%[fx:int(u*100)]' info:)
        neg=""
        if [ "$lum" -lt 50 ]; then neg="-negate"; fi
        magick $src/$n.png -colorspace Gray $neg \
          -auto-threshold OTSU -type bilevel traced/$n.pbm
      fi

      # shows up in `nix log`: 1 = all white (empty), 0 = all black
      magick identify -format "$n amin=$amin mean=%[fx:mean]\n" traced/$n.pbm

      potrace -e --flat -t 10 -O 0.4 -o traced/$n.eps traced/$n.pbm
    done

    cat > build.py <<'PY'
    import sys
    import fontforge
    import psMat

    src, out = sys.argv[1], sys.argv[2]

    font = fontforge.font()
    font.familyname = "BongoCat"
    font.fullname = "BongoCat"
    font.fontname = "BongoCat"
    font.em = 1000
    font.ascent = 800
    font.descent = 200

    H = 700
    BASE = 0      # vertical shift (negative = lower)

    for i, name in enumerate(["idle", "left", "right"]):
        g = font.createChar(0xE100 + i)
        g.importOutlines(src + "/" + name + ".eps")
        bb = g.boundingBox()
        if bb[3] - bb[1] == 0:
            sys.exit("empty glyph for " + name)
        g.transform(psMat.translate(-bb[0], -bb[1]))
        s = H / (bb[3] - bb[1])
        g.transform(psMat.scale(s))
        g.transform(psMat.translate(0, BASE))
        g.width = int((bb[2] - bb[0]) * s) + 60

    font.generate(out)
    PY

    fontforge -lang=py -script build.py traced $out/share/fonts/truetype/BongoCat.ttf
  ''