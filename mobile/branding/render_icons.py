"""Lokman logosunu (beyaz karo üzerinde mavi çerçeve içinde ters üçgen) üretir.

Tek doğruluk kaynağı bu betikteki geometridir. Çalıştırınca:
  - branding/lokman-logo.svg
  - android/app/src/main/res/drawable/ic_launcher_foreground.xml (uyarlanabilir simge ön planı)
  - android/app/src/main/res/drawable/ic_notification.xml
  - android/app/src/main/res/mipmap-*/ic_launcher.png (Android 7 ve öncesi)
  - fastlane/metadata/android/en-US/images/{icon.png, featureGraphic.png} (F-Droid)
dosyalarını yeniden yazar ve lib/widgets/lokman_logo.dart için yol komutlarını yazdırır.

Kullanım (mobile/ klasöründen): python3 branding/render_icons.py
"""

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

WHITE = "#FFFFFF"
DEEP_BLUE = "#0D47A1"  # çerçeve
BLUE = "#1E88E5"  # üçgen

STROKE = 3.6  # çizgi kalınlığı (48x48 birimlik alanda)

# Her şekil, köşeleri yuvarlatılmış kalın bir çizgidir: "çekirdek" çokgen dışa doğru
# d kadar büyütülür (köşelerde d yarıçaplı yay). Dış kenar d_dış, iç kenar d_dış - STROKE.
# Çokgenler ekranda saat yönünde sıralıdır (y aşağı).

# Çerçeve: dış sınırı 4..44, köşe yarıçapı 9.
FRAME_CORE = [(13.0, 13.0), (35.0, 13.0), (35.0, 35.0), (13.0, 35.0)]
FRAME_OUTER = 9.0

# Üçgen: ucu aşağı bakan eşkenar; dış sınırının kutusu ortada, genişliği 24.
TRI_WIDTH = 16.0
TRI_HEIGHT = TRI_WIDTH * math.sqrt(3) / 2
TRI_OUTER = 4.0
TRI_TOP = 24.0 - (TRI_HEIGHT + 2 * TRI_OUTER) / 2 + TRI_OUTER
TRI_CORE = [
    (24.0 - TRI_WIDTH / 2, TRI_TOP),
    (24.0 + TRI_WIDTH / 2, TRI_TOP),
    (24.0, TRI_TOP + TRI_HEIGHT),
]


def fmt(v):
    s = f"{v:.2f}".rstrip("0").rstrip(".")
    return "0" if s == "-0" else s


def outward_normals(poly):
    cx = sum(p[0] for p in poly) / len(poly)
    cy = sum(p[1] for p in poly) / len(poly)
    normals = []
    for i, a in enumerate(poly):
        b = poly[(i + 1) % len(poly)]
        dx, dy = b[0] - a[0], b[1] - a[1]
        length = math.hypot(dx, dy)
        n = (dy / length, -dx / length)
        mx, my = (a[0] + b[0]) / 2, (a[1] + b[1]) / 2
        if n[0] * (mx - cx) + n[1] * (my - cy) < 0:
            n = (-n[0], -n[1])
        normals.append(n)
    return normals


def ring(poly, d):
    """Çekirdeği d kadar büyütülmüş yuvarlak köşeli şekil: [başlangıç, (kenar sonu, yay sonu, merkez)...]."""
    normals = outward_normals(poly)
    k = len(poly)
    start = (poly[0][0] + d * normals[0][0], poly[0][1] + d * normals[0][1])
    steps = []
    for i in range(k):
        v = poly[(i + 1) % k]
        n_in, n_out = normals[i], normals[(i + 1) % k]
        line_end = (v[0] + d * n_in[0], v[1] + d * n_in[1])
        arc_end = (v[0] + d * n_out[0], v[1] + d * n_out[1])
        steps.append((line_end, arc_end, v))
    return start, steps, d


def svg_path(r, scale=1.0, dx=0.0, dy=0.0):
    start, steps, d = r
    t = lambda p: f"{fmt(dx + p[0] * scale)},{fmt(dy + p[1] * scale)}"
    out = f"M{t(start)}"
    for line_end, arc_end, _ in steps:
        out += f"L{t(line_end)}A{fmt(d * scale)},{fmt(d * scale)} 0 0,1 {t(arc_end)}"
    return out + "Z"


def dart_path(r):
    start, steps, d = r
    o = lambda p: f"{fmt(p[0])}, {fmt(p[1])}"
    lines = [f"..moveTo({o(start)})"]
    for line_end, arc_end, _ in steps:
        lines.append(f"..lineTo({o(line_end)})")
        lines.append(f"..arcToPoint(const Offset({o(arc_end)}), radius: const Radius.circular({fmt(d)}))")
    lines.append("..close()")
    return "\n".join(lines)


def polygon(r, n=24):
    start, steps, d = r
    pts = [start]
    for line_end, arc_end, c in steps:
        pts.append(line_end)
        a0 = math.atan2(line_end[1] - c[1], line_end[0] - c[0])
        a1 = math.atan2(arc_end[1] - c[1], arc_end[0] - c[0])
        if a1 < a0:
            a1 += 2 * math.pi
        for i in range(1, n + 1):
            a = a0 + (a1 - a0) * i / n
            pts.append((c[0] + d * math.cos(a), c[1] + d * math.sin(a)))
    return pts


FRAME = (ring(FRAME_CORE, FRAME_OUTER), ring(FRAME_CORE, FRAME_OUTER - STROKE))
TRIANGLE = (ring(TRI_CORE, TRI_OUTER), ring(TRI_CORE, TRI_OUTER - STROKE))


def shape_path(shape, **kw):
    return svg_path(shape[0], **kw) + svg_path(shape[1], **kw)


def hex_rgba(h):
    return tuple(int(h[i : i + 2], 16) for i in (1, 3, 5)) + (255,)


def logo_image(size):
    ss = 8  # kenar yumuşatma için büyük çizip küçült
    s = size * ss
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    scale = s * 0.92 / 40.0  # çerçeve (40 birim) simgenin %92'si
    o = s / 2 - 24 * scale
    tr = lambda pts: [(o + x * scale, o + y * scale) for x, y in pts]
    # Dış halkayı renkle, iç halkayı karo rengiyle boya.
    d.polygon(tr(polygon(FRAME[0])), fill=hex_rgba(DEEP_BLUE))
    d.polygon(tr(polygon(FRAME[1])), fill=hex_rgba(WHITE))
    d.polygon(tr(polygon(TRIANGLE[0])), fill=hex_rgba(BLUE))
    d.polygon(tr(polygon(TRIANGLE[1])), fill=hex_rgba(WHITE))
    return img.resize((size, size), Image.LANCZOS)


def render_png(size, out):
    logo_image(size).save(out)


def render_feature_graphic(root, out, w=1024, h=500):
    """F-Droid'in uygulama sayfasının üstünde gösterdiği afiş (1024x500)."""
    img = Image.new("RGB", (w, h), hex_rgba(WHITE)[:3])
    logo = logo_image(round(h * 0.56))
    left = round(h * 0.19)
    img.paste(logo, (left, (h - logo.height) // 2), logo)

    fonts = root / "assets" / "fonts"
    title = ImageFont.truetype(str(fonts / "DejaVuSans-Bold.ttf"), 104)
    subtitle = ImageFont.truetype(str(fonts / "DejaVuSans.ttf"), 38)
    d = ImageDraw.Draw(img)
    x = left + logo.width + round(h * 0.10)
    d.text((x, h / 2 - 16), "Lokman", font=title, anchor="ls", fill=hex_rgba(DEEP_BLUE)[:3])
    d.text(
        (x + 4, h / 2 + 64),
        "Ailenin kişisel sağlık defteri",
        font=subtitle,
        anchor="ls",
        fill=(0x55, 0x5F, 0x6B),
    )
    img.save(out)


def main():
    root = Path(__file__).resolve().parent.parent
    res = root / "android/app/src/main/res"

    (root / "branding" / "lokman-logo.svg").write_text(
        f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="512" height="512">
  <title>Lokman</title>
  <path fill="{WHITE}" d="{svg_path(FRAME[0])}"/>
  <path fill="{DEEP_BLUE}" fill-rule="evenodd" d="{shape_path(FRAME)}"/>
  <path fill="{BLUE}" fill-rule="evenodd" d="{shape_path(TRIANGLE)}"/>
</svg>
"""
    )

    # Uyarlanabilir simge: 108dp tuval, maske dairesi 66dp çaplı güvenli alan; çerçeve 52dp.
    fg = dict(scale=1.3, dx=54 - 24 * 1.3, dy=54 - 24 * 1.3)
    (res / "drawable" / "ic_launcher_foreground.xml").write_text(
        f"""<?xml version="1.0" encoding="utf-8"?>
<!-- Uygulama simgesi ön planı: mavi çerçeve içinde ters üçgen (108dp, güvenli alan 66dp).
     Arka plan beyazdır (values/ic_launcher_background.xml). Şekiller oyuk olduğu için
     temalı (monochrome) simgede de görünür.
     Bu dosya branding/render_icons.py ile üretilir; elle düzenlemeyin. -->
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <path
        android:fillColor="#FF{DEEP_BLUE[1:]}"
        android:fillType="evenOdd"
        android:pathData="{shape_path(FRAME, **fg)}" />
    <path
        android:fillColor="#FF{BLUE[1:]}"
        android:fillType="evenOdd"
        android:pathData="{shape_path(TRIANGLE, **fg)}" />
</vector>
"""
    )

    (res / "drawable" / "ic_notification.xml").write_text(
        f"""<?xml version="1.0" encoding="utf-8"?>
<!-- Bildirim simgesi: tek renkli (beyaz) çerçeve içinde ters üçgen.
     Bu dosya branding/render_icons.py ile üretilir; elle düzenlemeyin. -->
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#FFFFFFFF"
        android:fillType="evenOdd"
        android:pathData="{shape_path(FRAME, scale=0.5)}{shape_path(TRIANGLE, scale=0.5)}" />
</vector>
"""
    )

    for folder, size in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
        render_png(size, res / f"mipmap-{folder}" / "ic_launcher.png")

    # F-Droid listelemesinin görselleri (bkz. docs/FDROID.md). Ekran görüntüleri
    # elle çekilir; simge ve afiş buradan üretilir.
    images = root / "fastlane/metadata/android/en-US/images"
    images.mkdir(parents=True, exist_ok=True)
    render_png(512, images / "icon.png")
    render_feature_graphic(root, images / "featureGraphic.png")

    for name, shape in (("frame", FRAME), ("triangle", TRIANGLE)):
        print(f"// {name}")
        print(dart_path(shape[0]))
        print(dart_path(shape[1]))


if __name__ == "__main__":
    main()
