"""Lokman logosunu (beyaz kalp içinde hilal oyuğu) üretir.

Tek doğruluk kaynağı bu betikteki geometridir. Çalıştırınca:
  - branding/lokman-logo.svg
  - android/app/src/main/res/mipmap-*/ic_launcher.png (Android 7 ve öncesi)
dosyalarını yeniden yazar ve Android vektör ön planı için pathData'yı yazdırır.

Kullanım (mobile/ klasöründen): python3 branding/render_icons.py
"""

import math
from pathlib import Path

from PIL import Image, ImageDraw

TEAL = (0x00, 0x69, 0x6B, 255)
WHITE = (255, 255, 255, 255)

# Kalp: 48x48 birimlik alanda, Android vektöründeki yolun mutlak koordinatlı hali.
HEART_START = (24.0, 46.3)
HEART_SEGMENTS = [
    ("L", (21.1, 43.66)),
    ("C", (10.8, 34.32), (4.0, 28.16), (4.0, 20.6)),
    ("C", (4.0, 14.44), (8.84, 9.6), (15.0, 9.6)),
    ("C", (18.48, 9.6), (21.82, 11.22), (24.0, 13.78)),
    ("C", (26.18, 11.22), (29.52, 9.6), (33.0, 9.6)),
    ("C", (39.16, 9.6), (44.0, 14.44), (44.0, 20.6)),
    ("C", (44.0, 28.16), (37.2, 34.32), (26.9, 43.68)),
    ("L", (24.0, 46.3)),
]
HEART_PATH = (
    "M24,46.3L21.1,43.66C10.8,34.32 4,28.16 4,20.6C4,14.44 8.84,9.6 15,9.6"
    "C18.48,9.6 21.82,11.22 24,13.78C26.18,11.22 29.52,9.6 33,9.6"
    "C39.16,9.6 44,14.44 44,20.6C44,28.16 37.2,34.32 26.9,43.68L24,46.3Z"
)

# Hilal: dış daireden, sağa kaydırılmış iç dairenin çıkarılmasıyla oluşur (ağzı sağa bakar).
OUTER = ((22.6, 27.0), 10.0)
INNER = ((26.4, 25.6), 8.2)


def circle_intersections(c1, r1, c2, r2):
    (x1, y1), (x2, y2) = c1, c2
    d = math.hypot(x2 - x1, y2 - y1)
    a = (r1 * r1 - r2 * r2 + d * d) / (2 * d)
    h = math.sqrt(r1 * r1 - a * a)
    xm, ym = x1 + a * (x2 - x1) / d, y1 + a * (y2 - y1) / d
    p = (xm + h * (y2 - y1) / d, ym - h * (x2 - x1) / d)
    q = (xm - h * (y2 - y1) / d, ym + h * (x2 - x1) / d)
    return sorted([p, q], key=lambda pt: pt[1])  # üstteki önce


def fmt(v):
    return f"{v:.2f}".rstrip("0").rstrip(".")


def crescent_path():
    (c1, r1), (c2, r2) = OUTER, INNER
    top, bottom = circle_intersections(c1, r1, c2, r2)
    # Üstten dış dairenin sol (uzun) yayıyla alta, iç dairenin sol yayıyla tekrar üste.
    return (
        f"M{fmt(top[0])},{fmt(top[1])}"
        f"A{fmt(r1)},{fmt(r1)} 0 1,0 {fmt(bottom[0])},{fmt(bottom[1])}"
        f"A{fmt(r2)},{fmt(r2)} 0 0,1 {fmt(top[0])},{fmt(top[1])}Z"
    )


def bezier(p0, p1, p2, p3, n=40):
    for i in range(1, n + 1):
        t = i / n
        mt = 1 - t
        yield (
            mt**3 * p0[0] + 3 * mt * mt * t * p1[0] + 3 * mt * t * t * p2[0] + t**3 * p3[0],
            mt**3 * p0[1] + 3 * mt * mt * t * p1[1] + 3 * mt * t * t * p2[1] + t**3 * p3[1],
        )


def heart_polygon():
    pts = [HEART_START]
    cur = HEART_START
    for seg in HEART_SEGMENTS:
        if seg[0] == "L":
            cur = seg[1]
            pts.append(cur)
        else:
            pts.extend(bezier(cur, seg[1], seg[2], seg[3]))
            cur = seg[3]
    return pts


def circle_polygon(center, r, n=180):
    return [(center[0] + r * math.cos(2 * math.pi * i / n), center[1] + r * math.sin(2 * math.pi * i / n)) for i in range(n)]


def render_png(size, out):
    ss = 8  # kenar yumuşatma için büyük çizip küçült
    s = size * ss
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([0, 0, s - 1, s - 1], fill=TEAL)
    scale = s * 0.6 / 40.0  # kalp genişliği (40 birim) simgenin %60'ı
    ox, oy = s / 2 - 24 * scale, s / 2 - 27.5 * scale
    tr = lambda pts: [(ox + x * scale, oy + y * scale) for x, y in pts]
    d.polygon(tr(heart_polygon()), fill=WHITE)
    # Hilal oyuğu: dış daireyi zemin rengiyle, iç daireyi kalp rengiyle boya.
    d.polygon(tr(circle_polygon(*OUTER)), fill=TEAL)
    d.polygon(tr(circle_polygon(*INNER)), fill=WHITE)
    img.resize((size, size), Image.LANCZOS).save(out)


def main():
    root = Path(__file__).resolve().parent.parent
    crescent = crescent_path()
    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="512" height="512">
  <title>Lokman</title>
  <circle cx="24" cy="24" r="24" fill="#00696B"/>
  <g transform="translate(24 24) scale(0.72) translate(-24 -27.5)">
    <path fill="#FFFFFF" fill-rule="evenodd" d="{HEART_PATH}{crescent}"/>
  </g>
</svg>
"""
    (root / "branding" / "lokman-logo.svg").write_text(svg)
    for folder, size in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
        render_png(size, root / "android/app/src/main/res" / f"mipmap-{folder}" / "ic_launcher.png")
    print("Android pathData:")
    print(HEART_PATH + crescent)


if __name__ == "__main__":
    main()
