# Lokman — Terminoloji Paketi ve Kaynak Araştırması

> Durum: **araştırma notu, karar bekliyor.** Kod yazılmadı.
> İlgili: [PLAN.md](PLAN.md), [VERITABANI.md](VERITABANI.md)

## 1. Alınan kararlar (fikir alışverişinden)
- Hastalık, aşı, ilaç ve alerji listeleri tek bir yerden gelir: proje tarafından sürümlenen **Lokman Terminoloji Paketi**.
- Mobilde paket uygulamanın içine gömülü gelir ve **yalnızca uygulama güncellemesiyle** yenilenir. Uygulama kendiliğinden internete çıkmaz; tek istisna QR ile veri indirmektir.
- Aşılar **SKRS** ve **SNOMED CT GPS** kodlarıyla eşlenir.
- Hastalıklarda yalnızca ICD-10 kullanılır, ICD-10 dışında başka bir sistem eklenmez. Mobilde tam liste olur ve **halk dilinde eş anlamlılarla** aranır ("yüksek tansiyon" → I10).
- İlaç girişinde **TİTCK listesi** uygulamanın içinde olur: ilaç adla ya da barkod okutularak seçilir.
- Mevcut kodsuz kayıtlar paket geldiğinde **otomatik eşleştirilir**; uygulama emin olamazsa kullanıcıya sorar.
- Ulusal aşı takvimi **kapsam dışıdır**.

## 2. Kaynakların dağıtım koşulları (araştırma bulguları)

| Kaynak | Ne için | Açık kaynak uygulamaya gömülebilir mi? | Not |
|---|---|---|---|
| **SNOMED CT Global Patient Set (GPS)** | Aşı, hastalık, alerji kavramları | **Evet.** CC BY 4.0; yeniden dağıtım ve türev ürün serbest | SNOMED'in desteği ima edilemez; logo ve marka için yazılı izin gerekir. Tam SNOMED CT değil, ücretsiz bir alt küme. İçerik İngilizce; Türkçe adları proje yazar |
| **WHO ICD-10** | Hastalık kodları | **Hayır, izin gerekiyor.** Yeniden dağıtım WHO iznine bağlı. Kodların açık kaynak lisansla dağıtılmaması ve içeriğin değiştirilmemesi isteniyor | Bulgu WHO'nun bir izin yazısına ve satıcı sözleşmelerine dayanıyor; güncel resmi metin WHO'dan teyit edilmeli |
| **WHO ICD-11** | Hastalık kodları | **Büyük olasılıkla evet.** CC BY-ND 3.0 IGO; WHO, yazılıma dahil etmeyi "uyarlama" saymıyor (atıf korunmalı, kodlar değiştirilmemeli) | Resmi bir **Türkçe çevirisi** var. Ancak Türkiye klinikleri hâlâ ICD-10 kullanıyor |
| **SKRS (Sağlık Bakanlığı)** | Türkçe ICD-10 adları, aşı kodları | **Belirsiz.** Kod listeleri ve web servisleri var (`skrs.saglik.gov.tr`), ama kullanım ve yeniden dağıtım koşulları bulunamadı; giriş gerekebilir | Bakanlığa yazılı sorulmalı |
| **TİTCK ilaç listesi** | İlaç adı, barkod, etken madde, ATC | **Belirsiz.** Haftalık yayımlanıyor; üçüncü taraf siteler kullanıyor, ama kullanım koşulları bulunamadı | TİTCK'ye yazılı sorulmalı |
| **LOINC / UCUM** | Ölçüm türleri ve birimleri | Evet (mevcut uygulamada zaten kullanılıyor) | LOINC lisansının atıf koşulu kontrol edilmeli |

## 3. Sonuç: "tam ICD-10'u uygulamaya göm" kararı şu hâliyle uygulanamaz
Lokman MIT lisanslı. WHO'nun ICD-10 koşulları ise yeniden dağıtımı izne bağlıyor ve kodların açık kaynak lisans altına girmesini istemiyor. Tam ICD-10 listesini izin almadan uygulamanın içine koymak lisans riski taşıyor.

Seçenekler:

| Seçenek | Hasta ne görür | Artı | Eksi |
|---|---|---|---|
| **A. SNOMED GPS tabanlı derlenmiş liste** | Proje hazırlar: ~300–500 sık hastalık, Türkçe ve halk diliyle aranır, SNOMED kodlu | Lisans temiz; hasta için yeterli; IPS'in tercih ettiği sistem | Türkçe adlar proje emeği. Klinikten gelen ICD-10 kodları yine saklanır, ama mobil listede ICD-10 araması olmaz |
| **B. ICD-11 Türkçe** | Tam ICD-11 listesi | Resmi Türkçe çeviri var, lisans uygun | Türkiye'de klinikler ICD-10 kullanıyor; eşleme gerekir; liste hasta için fazla teknik |
| **C. WHO'dan ICD-10 izni** | Tam ICD-10 listesi (ilk karar) | İlk karara en yakın seçenek | İzin süreci belirsiz ve uzun. Türkçe adlar için ayrıca Bakanlık izni gerekir |

**Öneri:** A ile başla, C için paralel başvuru yap. İzin çıkarsa ICD-10 listesi ayrı bir veri paketi olarak eklenir ve paket kendi lisans notunu taşır.

- Klinik sistemi bu sorundan etkilenmez: ICD-10'u yönetici kendi kaynağından (SKRS) içe aktarır, proje dağıtmaz.
- Paket, MIT lisanslı koddan **ayrı bir klasörde ve kendi lisans/atıf dosyasıyla** tutulur (`terminology/LICENSES.md`). Böylece her veri kaynağının koşulu ayrı izlenir.

## 4. Aşılar için durum
- Proje ~30–40 aşılık listeyi kendisi hazırlar: Türkçe ad, İngilizce ad, SNOMED GPS kodu.
- SNOMED GPS: lisans temiz.
- SKRS aşı kodları: yalnızca sayısal kodları kullanacağız, ama koşullar belirsiz. Bakanlık yanıtına kadar alan boş kalabilir; SNOMED kodu yeterli.

## 5. İlaçlar için durum
TİTCK listesinin uygulamada dağıtım izni belirsiz. Yanıt gelene kadar seçenekler:
- **(i)** Projenin kendi hazırladığı **etken madde listesi** (ATC grubu ve alerji eşleşmesi için yeterli) + ticari ad serbest metin olarak girilir.
- **(ii)** İzin çıkarsa TİTCK listesi (ad, barkod, etken madde, ATC) pakete eklenir; barkod okutma bu durumda çalışır.

## 6. Yapılacaklar (kod dışı)
- [ ] WHO'ya ICD-10 yeniden dağıtım izni başvurusu (açık kaynak, ücretsiz mobil uygulama)
- [ ] Sağlık Bakanlığı'na SKRS ICD-10 Türkçe adları ve aşı kodlarının kullanım koşulu sorusu
- [ ] TİTCK'ye ilaç listesinin uygulama içinde dağıtımı sorusu
- [ ] SNOMED GPS güncel sürümünü ve atıf metnini doğrulamak
- [ ] LOINC atıf koşulunu kontrol etmek

## Kaynaklar
- [SNOMED International Global Patient Set (GPS) package license](https://conf.spaces.snomed.org/wiki/spaces/RMT/pages/131958316/SNOMED+International+Global+Patient+Set+GPS+package+license)
- [SNOMED GPS Implementation Guide 2024](https://conf.spaces.snomed.org/wiki/spaces/RMT/pages/131958392)
- [HL7 Terminology: SNOMED GPS value set](https://terminology.hl7.org/ValueSet-snomed-intl-gps.html)
- [ICD-11 License (WHO)](https://icd.who.int/docs/icd-api/license)
- [ICD-11 2024 release (çeviriler arasında Türkçe)](https://www.who.int/japan/news/detail-global/08-02-2024-icd-11-2024-release)
- [CamCOPS: ICD-10 için WHO izin koşulları](https://camcops.readthedocs.io/en/latest/_sources/tasks/icd.rst.txt)
- [IMO Health: ICD-10-WHO kullanım koşulları](https://www.imohealth.com/wp-content/uploads/2019/08/ICD-10-WHO.pdf)
- [SKRS ana sayfa](https://skrs.saglik.gov.tr/), [SKRS servis dokümanı](https://skrs.saglik.gov.tr/doc/index.html)
- [SKRS aşı kodu güncellemesi (e-sağlık)](https://e-saglik.gov.tr/TR,6083/skrs-asi-kodu-ve-skrs-asi-dozu-kod-bilgileri-guncellemesi.html)
