{ pkgs }:

pkgs.runCommand "bongocat-font"
  {
    nativeBuildInputs = [ pkgs.fontforge pkgs.imagemagick pkgs.potrace ];
    src = ../zsh/bongocat;
  }
  ''
    export HOME=$TMPDIR
    mkdir -p $out/share/fonts/truetype traced

    # PNG -> black/white bitmap -> vector outline
    for n in idle left right; do
      # MODE "luma": dark pixels become the cat (transparent = white)
      magick $src/$n.png -background white -alpha remove -alpha off \
        -colorspace Gray -threshold 50% traced/$n.pbm

      # MODE "alpha" (swap in if "luma" gives a blank or inverted cat):
      # magick $src/$n.png -alpha extract -negate -threshold 50% traced/$n.pbm

      potrace -e -o traced/$n.eps traced/$n.pbm
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

    H = 1400      # glyph height in font units (bigger = bigger cat)
    BASE = -250   # vertical shift (negative = lower)

    for i, name in enumerate(["idle", "left", "right"]):
        g = font.createChar(0xE000 + i)
        g.importOutlines(src + "/" + name + ".eps")
        bb = g.boundingBox()
        g.transform(psMat.translate(-bb[0], -bb[1]))
        s = H / (bb[3] - bb[1])
        g.transform(psMat.scale(s))
        g.transform(psMat.translate(0, BASE))
        g.width = int((bb[2] - bb[0]) * s) + 60

    font.generate(out)
    PY

    fontforge -lang=py -script build.py traced $out/share/fonts/truetype/BongoCat.ttf
  ''