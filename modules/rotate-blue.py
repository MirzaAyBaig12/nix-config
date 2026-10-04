#!/usr/bin/env python3
"""Recolor every blue-ish color in the given CSS files with Catppuccin mauve.

Instead of just shifting the hue (which keeps libadwaita's saturated GNOME
purple), blues are replaced by Catppuccin Mauve (#cba6f7) mixed toward the
Catppuccin base (#1e1e2e) according to the original lightness: light blues
become plain mauve, darker blues become muted mauve-tinted dark shades.
Alpha is kept. Cyan/teal (hue < 200) and already-mauve colors are left alone.
Idempotent.
"""
import colorsys, re, sys

MAUVE = (203, 166, 247)  # #cba6f7
BASE = (30, 30, 46)      # #1e1e2e


def rotate(r, g, b):
    h, l, s = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
    if not (200 <= h * 360 <= 262 and s >= 0.35 and 0.10 < l < 0.97):
        return None
    t = min(1.0, max(0.0, (l - 0.15) / (0.75 - 0.15)))
    return tuple(round(BASE[i] * (1 - t) + MAUVE[i] * t) for i in range(3))


def hex_sub(m):
    v = m.group(1)
    out = rotate(*(int(v[i:i + 2], 16) for i in (0, 2, 4)))
    return m.group(0) if out is None else "#%02x%02x%02x" % out


def rgb_sub(m):
    r, g, b = int(m.group(2)), int(m.group(3)), int(m.group(4))
    out = rotate(r, g, b)
    if out is None:
        return m.group(0)
    tail = m.group(5) or ""
    return "%s(%d, %d, %d%s)" % (m.group(1), *out, tail)


# Catppuccin's own blue (and its derived hover/focus shades) map straight onto
# the mauve accent so buttons match the accent exactly instead of just the hue.
EXACT = (
    ("#89b4fa", "#cba6f7"),
    ("rgba(137, 180, 250,", "rgba(203, 166, 247,"),
    ("rgba(110, 143, 199, 0.961)", "rgba(162, 133, 198, 0.961)"),
)


def process(text):
    for a, b in EXACT:
        text = re.sub(re.escape(a), b, text, flags=re.I)
    text = re.sub(r"#([0-9a-fA-F]{6})\b", hex_sub, text)
    text = re.sub(
        r"(rgba?)\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(,\s*[\d.]+\s*)?\)",
        rgb_sub, text)
    return text


if __name__ == "__main__":
    if sys.argv[1:2] == ["--print"]:
        for v in sys.argv[2:]:
            print(v, "->", "#%02x%02x%02x" % (rotate(*(int(v.lstrip('#')[i:i+2], 16) for i in (0, 2, 4))) or (0, 0, 0)))
        sys.exit(0)
    for path in sys.argv[1:]:
        with open(path) as f:
            old = f.read()
        new = process(old)
        if new != old:
            with open(path, "w") as f:
                f.write(new)
