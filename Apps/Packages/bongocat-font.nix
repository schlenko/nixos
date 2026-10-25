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
      # brightness of the top-left pixel = background
      lum=$(magick $src/$n.png -background white -alpha remove -alpha off \
        -colorspace Gray -crop 1x1+0+0 +repage -format '%[fx:int(u*100)]' info:)

      # dark background -> invert, so the cat is always the dark part
      neg=""
      if [ "$lum" -lt 50 ]; then neg="-negate"; fi

      magick $src/$n.png -background white -alpha remove -alpha off \
        -colorspace Gray $neg -auto-threshold OTSU traced/$n.pbm

      potrace -s --flat -o traced/$n.svg traced/$n.pbm
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
        g.importOutlines(src + "/" + name + ".svg")
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