# Lokman — Terminoloji Paketi ve Kaynak Araştırması

> Durum: **kararlar alındı (hastalık kodlaması: ICD-11).** Kod yazılmadı.
> İlgili: [PLAN.md](PLAN.md), [VERITABANI.md](VERITABANI.md)

## 1. Alınan kararlar (fikir alışverişinden)
- Hastalık, aşı, ilaç ve alerji listeleri tek bir yerden gelir: proje tarafından sürümlenen **Lokman Terminoloji Paketi**.
- Mobilde paket uygulamanın içine gömülü gelir ve **yalnızca uygulama güncellemesiyle** yenilenir. Uygulama kendiliğinden internete çıkmaz; tek istisna QR ile veri indirmektir.
- Aşılar **SKRS** ve **SNOMED CT GPS** kodlarıyla eşlenir.
- Hastalık ve teşhis kodlaması **her yerde ICD-11** (mobil ve klinik sistemi). Mobilde tam liste olur ve resmî Türkçe adlar, ICD-11 indeks terimleri ve projenin eklediği **halk dili eş anlamlılarıyla** aranır ("yüksek tansiyon" → esansiyel hipertansiyon). Gerekçe ve ayrıntı: bölüm 3.
- İlaç girişinde **TİTCK listesi** uygulamanın içinde olur: ilaç adla ya da barkod okutularak seçilir.
- Mevcut kodsuz kayıtlar paket geldiğinde **otomatik eşleştirilir**; uygulama emin olamazsa kullanıcıya sorar.
- Ulusal aşı takvimi **kapsam dışıdır**.

## 2. Kaynakların dağıtım koşulları (araştırma bulguları)

| Kaynak | Ne için | Açık kaynak uygulamaya gömülebilir mi? | Not |
|---|---|---|---|
| **SNOMED CT Global Patient Set (GPS)** | Aşı, hastalık, alerji kavramları | **Evet.** CC BY 4.0; yeniden dağıtım ve türev ürün serbest | SNOMED'in desteği ima edilemez; logo ve marka için yazılı izin gerekir. Tam SNOMED CT değil, ücretsiz bir alt küme. İçerik İngilizce; Türkçe adları proje yazar |
| **WHO ICD-10** | Hastalık kodları | **Hayır, izin gerekiyor.** Yeniden dağıtım WHO iznine bağlı. Kodların açık kaynak lisansla dağıtılmaması ve içeriğin değiştirilmemesi isteniyor | Bulgu WHO'nun bir izin yazısına ve satıcı sözleşmelerine dayanıyor; güncel resmi metin WHO'dan teyit edilmeli |
| **WHO ICD-11** | Hastalık kodları | **Büyük olasılıkla evet.** CC BY-ND 3.0 IGO; WHO, yazılıma dahil etmeyi "uyarlama" saymıyor (atıf korunmalı, kodlar değiştirilmemeli) | Resmi bir **Türkçe çevirisi** var. Ancak Türkiye klinikleri hâlâ ICD-10 kullanıyor |
| **SKRS (Sağlık Bakanlığı)** | Aşı kodları (ICD-10 Türkçe adları artık gerekmiyor) | **Belirsiz.** Kod listeleri ve web servisleri var (`skrs.saglik.gov.tr`), ama kullanım ve yeniden dağıtım koşulları bulunamadı; giriş gerekebilir | Bakanlığa yazılı sorulmalı |
| **TİTCK ilaç listesi** | İlaç adı, barkod, etken madde, ATC | **Belirsiz.** Haftalık yayımlanıyor; üçüncü taraf siteler kullanıyor, ama kullanım koşulları bulunamadı | TİTCK'ye yazılı sorulmalı |
| **LOINC / UCUM** | Ölçüm türleri ve birimleri | Evet (mevcut uygulamada zaten kullanılıyor) | LOINC lisansının atıf koşulu kontrol edilmeli |

## 3. Karar: hastalık ve teşhis kodlaması ICD-11

### ICD-10 ile ICD-11 farkı
| | ICD-10 | ICD-11 |
|---|---|---|
| Yayın | 1990 (WHO) | 2019'da kabul edildi, 1 Ocak 2022'de yürürlükte |
| Kod biçimi | `J03.9` | `CA03` gibi 4+ karakter |
| Kapsam | ~14 bin kod | ~17 bin kategori + ~130 bin indeks terimi (eş anlamlılar, arama ifadeleri) |
| Ayrıntı | Tek kod | Kod birleştirme (postcoordination): sağ/sol, şiddet, anatomik bölge vb. |
| Tasarım | Kâğıt kökenli | Dijital: ücretsiz API, tarayıcı, kodlama aracı |
| Lisans | Yeniden dağıtım WHO iznine bağlı | CC BY-ND 3.0 IGO: yazılıma dahil etmek serbest (atıf korunur, kodlar değiştirilmez) |
| Türkçe | SKRS'de (koşulları belirsiz) | WHO'nun resmî Türkçe çevirisi |

### Neden ICD-11
- **Lisans temiz:** MIT lisanslı Lokman tam listeyi hem mobil uygulamada hem klinik kurulumunda dağıtabilir. ICD-10 için WHO izni gerekirdi.
- **Resmî Türkçe adlar** hazır; çeviri emeği yok.
- **Arama güçlü:** indeks terimleri sayesinde hasta ve doktor farklı ifadelerle bulur.
- Lokman e-Nabız/SGK'ya bağlı değil (bkz. PLAN.md), bu yüzden ICD-10 zorunluluğu yok.

### Uygulama kuralları
1. **Kod sistemi:** ICD-11 MMS, Türkçe + İngilizce ad. FHIR `system`: `http://id.who.int/icd/release/11/mms`. Paket hangi ICD-11 sürümünü içerdiğini kaydeder (ör. `2026-01`).
2. **v0.1'de yalnızca temel (stem) kodlar.** Kod birleştirme sonraki sürüme kalır.
3. **Kaynak:** WHO ICD-11 resmî sürüm dosyaları (Türkçe dahil) terminoloji paketine eklenir; atıf `terminology/LICENSES.md`'de. ICD-11 içeriği değiştirilmez; halk dili eş anlamlıları **ayrı bir dosyada** proje tarafından eklenir.
4. **Mobil ve klinik aynı paketi kullanır.** Klinikte ayrıca hastalık listesi yüklenmez.
5. **ICD-10 ile karşılaşma:** başka kurumdan ICD-10 (ya da ICD-10-CM) kodlu kayıt gelirse kayıpsız saklanır (`coding`), metniyle gösterilir, reddedilmez. WHO'nun ICD-10 ↔ ICD-11 eşleme tablosunun lisansı uygunsa ek olarak:
   - içe aktarımda ICD-11 karşılığı önerilir,
   - doktor ICD-10 kodunu yazarak da arama yapabilir,
   - dışa aktarımda ICD-10 karşılığı ek `coding` olarak yazılır.
   Bu üçü eşleme tablosunun lisansı doğrulanana kadar **opsiyonel**dir.

### Riskler
| Risk | Önlem |
|---|---|
| Türkiye/KKTC doktorlarının ICD-10 alışkanlığı | Güçlü Türkçe arama; eşleme tablosu uygunsa ICD-10 koduyla arama |
| İleride e-Nabız/SGK entegrasyonu gerekirse ICD-10 istenir | Ayrı bir ICD-11 → ICD-10 dönüştürücü katman (eşleme tablosuyla) |
| IPS validator'ın ICD-11 kodlarını kabulü | F0'da örnek paketlerle test |
| Türkçe çevirinin tamlığı | Eksik Türkçe adda İngilizce ad gösterilir; F0'da kontrol |

## 4. Aşılar için durum
- Proje ~30–40 aşılık listeyi kendisi hazırlar: Türkçe ad, İngilizce ad, SNOMED GPS kodu.
- SNOMED GPS: lisans temiz.
- SKRS aşı kodları: yalnızca sayısal kodları kullanacağız, ama koşullar belirsiz. Bakanlık yanıtına kadar alan boş kalabilir; SNOMED kodu yeterli.

## 5. İlaçlar için durum
TİTCK listesinin uygulamada dağıtım izni belirsiz. Yanıt gelene kadar seçenekler:
- **(i)** Projenin kendi hazırladığı **etken madde listesi** (ATC grubu ve alerji eşleşmesi için yeterli) + ticari ad serbest metin olarak girilir.
- **(ii)** İzin çıkarsa TİTCK listesi (ad, barkod, etken madde, ATC) pakete eklenir; barkod okutma bu durumda çalışır.

## 6. Yapılacaklar (kod dışı)
- [ ] ICD-11 Türkçe sürüm dosyalarını indirip tamlığını ve CC BY-ND atıf metnini doğrulamak
- [ ] WHO ICD-10 ↔ ICD-11 eşleme tablosunun lisansını doğrulamak
- [ ] Sağlık Bakanlığı'na SKRS aşı kodlarının kullanım koşulu sorusu (izin yazıları şimdilik hazırlanmayacak)
- [ ] TİTCK'ye ilaç listesinin uygulama içinde dağıtımı sorusu (şimdilik ertelendi)
- [ ] Mobil kodda ICD-10 referanslarını ICD-11'e çevirmek (`mobile/lib/fhir/fhir_common.dart`, `bundle_writer.dart`, `bundle_reader.dart`, `simple_record_screens.dart`) — kodlama aşamasında
- [ ] SNOMED GPS güncel sürümünü ve atıf metnini doğrulamak
- [ ] LOINC atıf koşulunu kontrol etmek

## Kaynaklar
- [SNOMED International Global Patient Set (GPS) package license](https://conf.spaces.snomed.org/wiki/spaces/RMT/pages/131958316/SNOMED+International+Global+Patient+Set+GPS+package+license)
- [SNOMED GPS Implementation Guide 2024](https://conf.spaces.snomed.org/wiki/spaces/RMT/pages/131958392)
- [HL7 Terminology: SNOMED GPS value set](https://terminology.hl7.org/ValueSet-snomed-intl-gps.html)
- [ICD-11 License (WHO)](https://icd.who.int/docs/icd-api/license)
- [ICD-11 2024 release (çeviriler arasında Türkçe)](https://www.who.int/japan/news/detail-global/08-02-2024-icd-11-2024-release)
- [WHO: ICD-11 yürürlüğe girdi (2022)](https://www.who.int/news/item/11-02-2022-who-s-new-international-classification-of-diseases-(icd-11)-comes-into-effect)
- [CamCOPS: ICD-10 için WHO izin koşulları](https://camcops.readthedocs.io/en/latest/_sources/tasks/icd.rst.txt)
- [IMO Health: ICD-10-WHO kullanım koşulları](https://www.imohealth.com/wp-content/uploads/2019/08/ICD-10-WHO.pdf)
- [SKRS ana sayfa](https://skrs.saglik.gov.tr/), [SKRS servis dokümanı](https://skrs.saglik.gov.tr/doc/index.html)
- [SKRS aşı kodu güncellemesi (e-sağlık)](https://e-saglik.gov.tr/TR,6083/skrs-asi-kodu-ve-skrs-asi-dozu-kod-bilgileri-guncellemesi.html)
