# Terminoloji paketi — kaynaklar ve lisanslar

Bu klasörden üretilen varlıklar (`mobile/assets/terminology/`) üçüncü taraf
sınıflandırma içeriği taşır. Lokman'ın kendi kodu MIT lisanslıdır; aşağıdaki
içerik kendi lisansıyla gelir ve atıf zorunludur.

## WHO ICD-11 (MMS linearizasyonu, Türkçe + İngilizce)

- **Sürüm:** ICD-11 for Mortality and Morbidity Statistics (MMS), 2025-01
- **Kaynak dosyalar:**
  - `https://icdcdn.who.int/static/releasefiles/2025-01/SimpleTabulation-ICD-11-MMS-tr.zip`
  - `https://icdcdn.who.int/static/releasefiles/2025-01/mapping.zip`
    (ICD-10 ↔ ICD-11 eşleme tabloları)
- **Lisans:** Creative Commons Attribution-NoDerivs 3.0 IGO (CC BY-ND 3.0 IGO)
  — <https://creativecommons.org/licenses/by-nd/3.0/igo/>
- **Lisans metni:** <https://icd.who.int/docs/icd-api/license> ve
  <https://icd.who.int/en/docs/icd11-license.pdf>

**Atıf:** International Classification of Diseases, Eleventh Revision
(ICD-11), World Health Organization (WHO) 2019/2025.
<https://icd.who.int/browse11>. Licensed under Creative Commons
Attribution-NoDerivatives 3.0 IGO licence (CC BY-ND 3.0 IGO).

### NoDerivs koşuluna nasıl uyuluyor

- ICD-11 **içeriği değiştirilmez**: kodlar ve resmî adlar WHO sürüm
  dosyasındaki haliyle aktarılır. `terminology/build.py` yalnızca biçim
  dönüştürür (sekmeli metne yazar, satır başındaki `- - -` derinlik
  işaretlerini atar) ve mobil uygulamada kullanılan bölümleri seçer.
- Projenin eklediği **halk dili eş anlamlıları ayrı dosyada** tutulur
  (`synonyms/icd11-tr-halk.tsv`, MIT) ve resmî adların yerine geçmez; aramada
  ek anahtar olarak kullanılır, kullanıcıya her zaman resmî ad gösterilir.
- Uygulama, lisans ekranında (Ayarlar → Lokman) yukarıdaki atfı gösterir.
- WHO, sınıflandırmanın yazılıma dahil edilmesini "uyarlama" saymaz; bkz.
  lisans metni ve `docs/TERMINOLOJI.md` §3.

### Pakete girmeyen bölümler

Mobil varlık ICD-11 MMS'in 01–25 numaralı tanı bölümlerini içerir
(17.231 kategori). Girmeyenler: `X` (uzatma kodları — tek başına tanı
değildir, kod birleştirmede kullanılır), `V` (işlevsellik değerlendirmesi) ve
`26` (geleneksel tıp durumları). Dışarıdan bu bölümlerden kod gelirse kayıt
reddedilmez: kod ve kod sistemi olduğu gibi saklanır.

## Henüz pakette olmayan kaynaklar

| Kaynak | Ne için | Durum |
|---|---|---|
| SNOMED CT Global Patient Set | Aşı kodları | CC BY 4.0; eklenmedi |
| ATC (WHOCC) | İlaç / alerji grupları | Liste dağıtılmıyor; proje kendi etken madde listesini yazacak |
| TİTCK ilaç listesi | İlaç adı, barkod | Dağıtım izni belirsiz |
| SKRS aşı kodları | Aşı kodları | Kullanım koşulları belirsiz |
| LOINC / UCUM | Ölçüm türleri ve birimleri | Uygulamada kullanılıyor (`mobile/lib/domain/catalog.dart`); atıf koşulu kontrol edilecek |

Ayrıntı ve araştırma notları: [../docs/TERMINOLOJI.md](../docs/TERMINOLOJI.md)
