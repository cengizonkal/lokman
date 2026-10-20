# Lokman Terminoloji Paketi

Hastalık, tanı, ilaç ve aşı listelerinin tek kaynağı. Mobil uygulama ve
(yazılacak) klinik sistemi aynı paketi kullanır; paket **uygulamanın içine
gömülü** gelir ve yalnızca uygulama güncellemesiyle yenilenir — uygulama
çalışırken internete çıkmaz (bkz. [../docs/TERMINOLOJI.md](../docs/TERMINOLOJI.md)).

Bugün pakette **ICD-11 MMS 2025-01** (hastalık ve tanı kodları) ve WHO'nun
**ICD-10 ↔ ICD-11 eşleme tablosu** var.

## Klasörler

```
build.py                      derleyici: WHO dosyalarını indirir, varlıkları üretir
sources/                      indirilen WHO zip'leri (depoya işlenmez)
synonyms/icd11-tr-halk.tsv    projenin yazdığı halk dili eş anlamlıları (MIT)
LICENSES.md                   kaynaklar, lisanslar, atıf metni
```

Üretilen ve **depoya işlenen** varlıklar:

```
mobile/assets/terminology/icd11-mms-2025-01.tsv     17.231 kategori (3,4 MB)
mobile/assets/terminology/icd10-icd11-2025-01.tsv   11.615 ICD-10 → ICD-11 eşlemesi
```

## Üretmek

```bash
python3 terminology/build.py                 # eksik kaynakları indirir, varlıkları yazar
python3 terminology/build.py --no-download   # yalnızca sources/ içindekilerle
python3 terminology/build.py --check         # varlıklar güncel mi (CI kullanır)
```

Çıktı değiştiyse hem `terminology/` hem `mobile/assets/terminology/`
değişiklikleri aynı işlemede (commit) gider.

## Varlık biçimi

Satır satır sekmeyle ayrılmış metin; `#` ile başlayan satırlar başlık ve bölüm
adlarıdır. Uygulama tarafı: `mobile/lib/domain/terminology/icd11.dart`.

```
#lokman-terminoloji  icd11-mms  2025-01  17231  2025 Jan 24 - 22:30 UTC
#bolum  11  Dolaşım Sistemi Hastalıkları
<arama>  <kod>  <Türkçe ad>  <İngilizce ad>  <bölüm>  <ICD-10>  <işaretler>
```

- **arama**: küçük harfli, Türkçe harfleri sadeleştirilmiş karşılıklar; `|` ile
  ayrılır (Türkçe ad, İngilizce ad, halk dili eş anlamlıları, kod). Ayraç
  sayesinde uygulama tam / baştan / kelime başı eşleşmesini ayırt edip
  sıralayabiliyor. Sadeleştirme kuralı `build.py` içindeki `FOLD` ile
  `icd11.dart` içindeki `_fold` arasında **birebir aynı** olmalı.
- **İngilizce ad**: Türkçesiyle aynıysa boş bırakılır.
- **ICD-10**: WHO'nun 11→10 eşlemesindeki karşılık; aralık (`J09-J18`) ya da
  bölüm (`IX`) olabilir, bunlar ICD-10 kodu değildir ve dışa aktarımda ikincil
  kodlama olarak yazılmaz.
- **işaretler**: `r` = "diğer / tanımlanmamış" kategori, `s` = tanının kendisi
  olmayan bölüm (23 dış nedenler, 24 sağlıkla temas etmeyi etkileyen etmenler).
  İkisi de aramada sonuçları geriye alır; `s`, `r`'den önce gelir çünkü
  "Kalp donörü" gibi bir kayıt hastanın aradığı şey olmaz.

## Eş anlamlı eklemek

`synonyms/icd11-tr-halk.tsv` dosyasına `<kod><TAB>eş;anlam;listesi` satırı
ekleyip `build.py`'yi çalıştırın. Kod ICD-11'de yoksa derleme hata verir.
Eş anlamlı yazarken tanıyı daraltmayın: halk "kalp yetmezliği" diyorsa kod
"tanımlanmamış" kategori olmalı, hastanın yerine daha özel bir kod seçilmemeli.

## Sürüm yükseltmek

1. `build.py` içindeki `RELEASE` değerini değiştirin.
2. `mobile/lib/domain/terminology/icd11.dart` içindeki `Icd11Asset.release`
   değerini aynı yapın (derleme bunu kontrol eder).
3. `python3 terminology/build.py` çalıştırın, eski varlık dosyalarını silin.
4. Testleri çalıştırın: `cd mobile && flutter test test/icd11_test.dart`
   (testler kod ve ad örnekleri doğruluyor).
5. Uygulama ilk açılışında kullanıcının kodsuz kayıtlarını yeni paketle bir kez
   eşleştirir (`Repository.applyTerminologyPackage`), bu yüzden sürüm adı
   ayarlarda saklanır.
