"""F-Droid üstverisinin sınırlara uyduğunu denetler.

F-Droid, uygulama sayfasının metinlerini depodaki
`mobile/fastlane/metadata/android/<dil>/` klasöründen okur ve sınırları aşan
dosyaları sessizce kırpar. Bu betik sınırları ve eksik dosyaları yayından önce
yakalar; CI (`.github/workflows/mobile-ci.yml`) her itmede çalıştırır.

Kullanım (mobile/ klasöründen): python3 fastlane/check_metadata.py
"""

import re
import sys
from pathlib import Path

# F-Droid'in sınırları: bkz. https://f-droid.org/docs/All_About_Descriptions_Graphics_and_Screenshots/
LIMITS = {
    "title.txt": 50,
    "short_description.txt": 80,
    "full_description.txt": 4000,
}
CHANGELOG_LIMIT = 500

root = Path(__file__).resolve().parent.parent
locales = sorted(p for p in (root / "fastlane/metadata/android").iterdir() if p.is_dir())
version = re.search(r"^version:\s*(\S+)\+(\d+)\s*$", (root / "pubspec.yaml").read_text(), re.M)
name, code = version.group(1), version.group(2)

errors = []
for locale in locales:
    for file, limit in LIMITS.items():
        path = locale / file
        if not path.exists():
            errors.append(f"{path.relative_to(root)} yok")
            continue
        length = len(path.read_text().strip())
        if length > limit:
            errors.append(f"{path.relative_to(root)}: {length} karakter, sınır {limit}")
    short = locale / "short_description.txt"
    if short.exists() and short.read_text().strip().endswith("."):
        errors.append(f"{short.relative_to(root)}: nokta ile bitmemeli")

    # Her sürümün kendi notu olmalı; dosya adı derleme numarasıdır.
    note = locale / "changelogs" / f"{code}.txt"
    if not note.exists():
        errors.append(f"{note.relative_to(root)} yok ({name}+{code} sürümünün notu)")
    elif len(note.read_text().strip()) > CHANGELOG_LIMIT:
        errors.append(
            f"{note.relative_to(root)}: {len(note.read_text().strip())} karakter, sınır {CHANGELOG_LIMIT}"
        )

# Listelemenin "En yeni" sekmesinde görünmesi için en az bir görsel gerekir.
images = root / "fastlane/metadata/android/en-US/images"
for file in ("icon.png", "featureGraphic.png"):
    if not (images / file).exists():
        errors.append(f"{(images / file).relative_to(root)} yok (python3 branding/render_icons.py)")
if not list((images / "phoneScreenshots").glob("*.png")):
    print("Uyarı: ekran görüntüsü yok; bkz. docs/FDROID.md", file=sys.stderr)

if errors:
    print("F-Droid üstverisi:", file=sys.stderr)
    for error in errors:
        print(f"  - {error}", file=sys.stderr)
    sys.exit(1)
print(f"F-Droid üstverisi {name}+{code} için tamam ({len(locales)} dil).")
