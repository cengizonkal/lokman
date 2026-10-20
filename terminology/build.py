#!/usr/bin/env python3
"""Lokman Terminoloji Paketi derleyicisi.

WHO ICD-11 MMS sürüm dosyalarından mobil uygulamanın içine gömülen varlıkları
üretir. Üretilen dosyalar depoya işlenir; uygulama çalışırken internete
çıkmadığı için paket yalnızca uygulama güncellemesiyle yenilenir.

Kullanım:
    python3 terminology/build.py              # eksik kaynakları indirir, üretir
    python3 terminology/build.py --no-download  # yalnızca yerel kaynaklarla
    python3 terminology/build.py --check      # üretilen dosyalar güncel mi (CI)

Kaynak dosyalar `terminology/sources/` içine indirilir ve depoya işlenmez.
Lisans ve atıf: terminology/LICENSES.md
"""

from __future__ import annotations

import argparse
import csv
import datetime as dt
import io
import re
import sys
import urllib.request
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parent
SOURCES = ROOT / "sources"
OUT_DIR = REPO / "mobile" / "assets" / "terminology"

RELEASE = "2025-01"
CDN = "https://icdcdn.who.int/static/releasefiles"

# İndirilecek WHO sürüm dosyaları.
FILES = {
    "mms_tr": "SimpleTabulation-ICD-11-MMS-tr.zip",
    "mapping": "mapping.zip",
}

# Mobil uygulamaya giren bölümler: tanı bölümleri (01–25).
# Dışarıda bırakılanlar, hepsi MMS'in ek bölümleri:
#   X  uzatma kodları — tek başına tanı değil, kod birleştirmede kullanılır
#      (bkz. docs/TERMINOLOJI.md §3: "v0.1'de yalnızca temel (stem) kodlar"),
#   V  işlevsellik değerlendirmesi,
#   26 geleneksel tıp durumları — aramada asıl tanıların önüne geçiyor.
# Dışarıdan bu bölümlerden kod gelirse kayıp olmaz: içe aktarımda kod ve
# sistem olduğu gibi saklanır (bkz. docs/PLAN.md §1.3 "katalogda olmayan kod").
SKIPPED_CHAPTERS = {"V", "X", "26"}

# Tanının kendisi olmayan bölümler: 23 morbidite/mortalitenin dış nedenleri,
# 24 sağlık durumunu veya sağlık hizmetleriyle temasını etkileyen etmenler
# ("Kalp donörü", "Aşı ihtiyacı" gibi). Pakete girerler ama aramada asıl
# tanıların arkasına alınırlar.
SECONDARY_CHAPTERS = {"23", "24"}

# Türkçe arama için harf sadeleştirme. Dart tarafındaki
# `mobile/lib/domain/terminology/normalize.dart` ile birebir aynı olmalı.
FOLD = {
    "ç": "c", "ğ": "g", "ı": "i", "İ": "i", "ö": "o", "ş": "s", "ü": "u",
    "â": "a", "ê": "e", "î": "i", "ô": "o", "û": "u", "á": "a", "é": "e",
    "í": "i", "ó": "o", "ú": "u", "à": "a", "è": "e", "ä": "a", "ë": "e",
    "ï": "i", "ñ": "n", "å": "a", "æ": "a", "ø": "o", "œ": "o", "ß": "s",
}


# Uygulamanın lisans ekranında gösterilen atıf (CC BY-ND 3.0 IGO şartı).
LICENSE_NOTICE = """Lokman Terminoloji Paketi — ICD-11 MMS {release}
WHO sürüm damgası: {version}

Hastalık ve tanı kodları Dünya Sağlık Örgütü'nün (WHO) ICD-11 sınıflandırmasından
alınmıştır:

International Classification of Diseases, Eleventh Revision (ICD-11),
World Health Organization (WHO) 2019/2025. https://icd.who.int/browse11
Licensed under Creative Commons Attribution-NoDerivatives 3.0 IGO licence
(CC BY-ND 3.0 IGO): https://creativecommons.org/licenses/by-nd/3.0/igo/

ICD-11 kodları ve resmî adları değiştirilmemiştir. Aramada kullanılan halk dili
eş anlamlıları Lokman projesinin katkısıdır (MIT lisansı) ve resmî adların
yerine geçmez.

ICD-10 karşılıkları WHO'nun ICD-10 / ICD-11 eşleme tablolarından gelir
(aynı lisans).
"""


def normalize(text: str) -> str:
    """Küçük harfli, Türkçe harfleri sadeleştirilmiş arama metni.

    Nokta silinir (`BA00.0` → `ba000`), diğer harf/rakam dışı karakterler
    boşluğa döner.
    """
    out = []
    for ch in text:
        ch = FOLD.get(ch, ch)
        ch = ch.lower()
        ch = FOLD.get(ch, ch)
        if ch.isascii() and ch.isalnum():
            out.append(ch)
        elif ch == ".":
            continue
        else:
            out.append(" ")
    return re.sub(r" +", " ", "".join(out)).strip()


def clean_title(title: str) -> str:
    """Satır başındaki derinlik işaretlerini (`- - - `) atar."""
    return re.sub(r"^(-\s*)+", "", title).strip()


def download(name: str, force: bool = False) -> Path:
    path = SOURCES / FILES[name]
    if path.exists() and not force:
        return path
    url = f"{CDN}/{RELEASE}/{FILES[name]}"
    print(f"indiriliyor: {url}")
    SOURCES.mkdir(parents=True, exist_ok=True)
    with urllib.request.urlopen(url, timeout=300) as r:
        data = r.read()
    path.write_bytes(data)
    print(f"  {len(data):,} bayt → {path.relative_to(REPO)}")
    return path


def read_zip_member(path: Path, suffix: str) -> str:
    with zipfile.ZipFile(path) as z:
        member = next(n for n in z.namelist() if n.endswith(suffix))
        return z.read(member).decode("utf-8-sig")


def rows(text: str) -> list[dict[str, str]]:
    return list(csv.DictReader(io.StringIO(text), delimiter="\t"))


def version_stamp(text: str) -> str:
    """WHO dosyasının başlık satırındaki son sütun sürüm damgasını taşır."""
    last = text.split("\n", 1)[0].rstrip("\r").split("\t")[-1].strip()
    return last.removeprefix("Version:").strip()


def load_synonyms(valid_codes: set[str]) -> dict[str, list[str]]:
    """Proje yazımı halk dili eş anlamlıları (`code<TAB>eş;anlam;...`)."""
    path = ROOT / "synonyms" / "icd11-tr-halk.tsv"
    result: dict[str, list[str]] = {}
    unknown: list[str] = []
    if not path.exists():
        return result
    for lineno, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        line = line.split("#", 1)[0].strip()
        if not line:
            continue
        parts = line.split("\t")
        if len(parts) < 2:
            sys.exit(f"{path.name}:{lineno}: kod ve eş anlamlı sütunu gerekli")
        code = parts[0].strip()
        if code not in valid_codes:
            unknown.append(f"{path.name}:{lineno}: bilinmeyen ICD-11 kodu {code}")
            continue
        terms = [t.strip() for t in parts[1].split(";") if t.strip()]
        result.setdefault(code, []).extend(terms)
    if unknown:
        sys.exit("\n".join(unknown))
    return result


def check_dart_release() -> None:
    """Mobil taraftaki `Icd11Asset.release` ile aynı sürümü mü üretiyoruz?"""
    path = REPO / "mobile" / "lib" / "domain" / "terminology" / "icd11.dart"
    text = path.read_text(encoding="utf-8")
    match = re.search(r"static const release = '([^']+)'", text)
    if not match:
        sys.exit(f"{path.name}: Icd11Asset.release bulunamadı")
    if match.group(1) != RELEASE:
        sys.exit(
            f"sürüm uyuşmuyor: build.py RELEASE={RELEASE}, "
            f"{path.name} Icd11Asset.release={match.group(1)}"
        )


def build() -> dict[str, str]:
    """Varlık dosyalarını üretir; {dosya adı: içerik} döner."""
    check_dart_release()
    mms_text = read_zip_member(download("mms_tr"), "-tr.txt")
    mms = rows(mms_text)
    version = version_stamp(mms_text)

    chapters = {
        r["ChapterNo"]: clean_title(r["Title"])
        for r in mms
        if r["ClassKind"] == "chapter"
    }
    cats = [
        r
        for r in mms
        if r["ClassKind"] == "category"
        and r["Code"]
        and r["ChapterNo"] not in SKIPPED_CHAPTERS
    ]
    codes = {r["Code"] for r in cats}

    mapping_zip = download("mapping")
    # ICD-11 → ICD-10 (dışa aktarımda ikincil kodlama için).
    out10: dict[str, str] = {}
    for r in rows(read_zip_member(mapping_zip, "11To10MapToOneCategory.txt")):
        c11, c10 = r["icd11Code"].strip(), r["icd10Code"].strip()
        if c11 and c10 and c11 not in out10:
            out10[c11] = c10
    # ICD-10 → ICD-11 (dışarıdan ICD-10 kodlu kayıt gelince ve ICD-10 koduyla
    # arama yapılınca karşılığını bulmak için).
    in10: dict[str, str] = {}
    for r in rows(read_zip_member(mapping_zip, "10To11MapToOneCategory.txt")):
        c10, c11 = r["icd10Code"].strip(), r["icd11Code"].strip()
        if c10 and c11 in codes and c10 not in in10:
            in10[c10] = c11

    synonyms = load_synonyms(codes)
    untranslated = 0
    residual = sum(1 for r in cats if r["IsResidual"] == "True")

    lines = [
        f"#lokman-terminoloji\ticd11-mms\t{RELEASE}\t{len(cats)}\t{version}",
    ]
    for no, title in sorted(chapters.items()):
        if no not in SKIPPED_CHAPTERS:
            lines.append(f"#bolum\t{no}\t{title}")

    for r in cats:
        code = r["Code"]
        tr = clean_title(r["Title"])
        en = clean_title(r["TitleEN"])
        if normalize(tr) == normalize(en):
            untranslated += 1
            en = ""  # Türkçesi yok ya da aynı: ikinci sütun boş kalır
        syn = synonyms.get(code, [])
        # Arama metni: her karşılık `|` ile ayrılır, böylece uygulama tam /
        # baştan / içinde eşleşmeyi karşılık sınırlarına göre puanlayabilir.
        alts = "|".join(
            dict.fromkeys(
                part
                for part in (
                    normalize(tr),
                    normalize(en),
                    *(normalize(s) for s in syn),
                    normalize(code),
                )
                if part
            )
        )
        lines.append(
            "\t".join(
                [
                    alts,
                    code,
                    tr,
                    en,
                    r["ChapterNo"],
                    out10.get(code, ""),
                    ("r" if r["IsResidual"] == "True" else "")
                    + ("s" if r["ChapterNo"] in SECONDARY_CHAPTERS else ""),
                ]
            )
        )

    icd10_lines = [f"#lokman-terminoloji\ticd10-icd11\t{RELEASE}\t{len(in10)}"]
    icd10_lines += [f"{c10}\t{c11}" for c10, c11 in sorted(in10.items())]

    print(
        f"ICD-11 MMS {RELEASE}: {len(cats):,} kategori "
        f"({untranslated:,} Türkçesi yok, %{untranslated / len(cats) * 100:.1f}), "
        f"{len(synonyms):,} kodda halk dili eş anlamlısı, "
        f"{residual:,} kalıntı kategori, "
        f"{len(out10):,} ICD-10 karşılığı, {len(in10):,} ICD-10 → ICD-11 eşlemesi"
    )
    return {
        f"icd11-mms-{RELEASE}.tsv": "\n".join(lines) + "\n",
        f"icd10-icd11-{RELEASE}.tsv": "\n".join(icd10_lines) + "\n",
        "LISANS.txt": LICENSE_NOTICE.format(release=RELEASE, version=version),
    }


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--no-download", action="store_true", help="indirme yapma")
    ap.add_argument("--check", action="store_true", help="güncel mi diye bak")
    args = ap.parse_args()

    if args.no_download:
        missing = [f for f in FILES.values() if not (SOURCES / f).exists()]
        if missing:
            sys.exit(f"kaynak dosya yok: {', '.join(missing)}")

    assets = build()
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    stale = []
    for name, content in assets.items():
        path = OUT_DIR / name
        current = path.read_text(encoding="utf-8") if path.exists() else None
        if args.check:
            if current != content:
                stale.append(name)
            continue
        if current != content:
            path.write_text(content, encoding="utf-8")
            print(f"yazıldı: {path.relative_to(REPO)} ({len(content):,} bayt)")
        else:
            print(f"değişmedi: {path.relative_to(REPO)}")

    if args.check:
        if stale:
            sys.exit(
                "güncel değil: " + ", ".join(stale) + "\n"
                "`python3 terminology/build.py` çalıştırıp sonucu işleyin."
            )
        print(f"güncel ({dt.date.today()})")


if __name__ == "__main__":
    main()
