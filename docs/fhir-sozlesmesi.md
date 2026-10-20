# FHIR değişim sözleşmesi (taslak)

> Durum: **taslak.** Mobil uygulamanın (v0.1) okuduğu ve ürettiği alanları tanımlar. Klinik sistemi (F3) yazılırken tamamlanacak.
> İlgili: [PLAN.md §4](PLAN.md#4-fhir-değişim-sözleşmesi), örnek paket: [`fhir/examples/klinik-cikti-ayse.json`](../fhir/examples/klinik-cikti-ayse.json)

## 1. Paket

- `Bundle.type = document`, ilk kaynak `Composition` (LOINC `60591-5`), ardından `Patient`.
- `Bundle.meta.profile`: `http://hl7.org/fhir/uv/ips/StructureDefinition/Bundle-uv-ips`
- Kaynaklar `fullUrl = urn:uuid:<id>` ile yer alır; referanslar `urn:uuid:` biçimindedir.
- Klinik çıktısında `Composition.custodian` (yoksa `author`) kliniğin `Organization` kaynağını gösterir. Organization kimliği: `urn:lokman:installation` | `<kurulum-uuid>`.

### Composition bölümleri

| Bölüm | LOINC | İçerik | Boş olabilir mi |
|---|---|---|---|
| Alerjiler | `48765-2` | AllergyIntolerance | Hayır: boşsa `emptyReason` |
| Aktif problemler | `11450-4` | Condition (`problem-list-item`, devam eden) | Hayır: boşsa `emptyReason` |
| Geçirilmiş hastalıklar | `11348-0` | Condition (`problem-list-item`, `clinicalStatus` = `resolved`) | Evet |
| İlaçlar | `10160-0` | MedicationRequest | Hayır: boşsa `emptyReason` |
| Aşılar | `11369-6` | Immunization | Evet (bölüm yazılmaz) |
| Vital bulgular | `8716-3` | Observation | Evet |
| Muayeneler | `46240-8` | Encounter + Condition (`encounter-diagnosis`) | Evet |
| Plan | `18776-5` | Appointment + ImmunizationRecommendation | Evet |

Her bölümde `text` (oluşturulmuş XHTML özet) bulunur.

## 2. Kimlikler

| Ne | Kimlik |
|---|---|
| Klinikteki hasta | `Patient.identifier`: `urn:lokman:<kurulum-uuid>:patient` \| `<hasta-uuid>` |
| Mobil profil | `Patient.identifier`: `urn:lokman:app:<uygulama-uuid>:profile` \| `<profil-uuid>` |
| Kaynak sistemi | `meta.source`: klinik `urn:lokman:installation:<kurulum-uuid>`, mobil `urn:lokman:app:<uygulama-uuid>` |

Mobil, bir dosyayı içe aktarırken:

1. `Patient.identifier` daha önce bir profile bağlandıysa o profile aktarır, sormaz.
2. Bağlı değilse “Bu dosya kime ait?” diye sorar; ad + doğum tarihine göre öneri yapar ya da yeni profil açar. Seçimden sonra dosyadaki tüm hasta kimlikleri profile bağlanır.
3. Mobil dışa aktarımda `Patient.identifier`'a hem kendi profil kimliğini hem de bağlı klinik kimliklerini yazar; böylece klinik kendi hastasını tanır.

### Kayıt kimliği ve tekrar aktarım

- Her kaydın kaynak sistemdeki kimliği **origin-ref**'tir: `<kaynak>|<Tür>/<id>`. `<kaynak>`, `meta.source`; yoksa paketin Organization kimliği (`system|value`).
- Mobil, origin-ref'i kayıtla saklar (tekil). Aynı dosya tekrar gelirse kayıt güncellenir, çoğalmaz.
- Mobil, **iletilen** kayıtlarda (klinikten gelmiş ya da başka telefondan aktarılmış) asıl origin-ref'i taşır:
  `identifier`: `urn:lokman:origin-ref` \| `<kaynak>|<Tür>/<id>`. Okuyan taraf bu kimlik varsa onu kullanır.
- Mobilin kendi kayıtlarında (kullanıcının girdikleri) origin-ref yoktur; `meta.source` uygulamanın kendisidir ve `id` doğrudan kayıt kimliğidir.

### Kaydın kaynağı

`meta.tag` (system `urn:lokman:record-source`):

| code | Anlamı | display |
|---|---|---|
| `patient-reported` | Hasta / ebeveyn beyanı | `Hasta beyanı` |
| `external` | Kurumdan gelen kayıt | Kurum adı |

Etiket yoksa kayıt, paketi üreten kurumun (Organization) kaydı sayılır. Klinik sistemi `patient-reported` kayıtları onay kuyruğuna, `external` kayıtları dış kaynaklı (salt okunur) kayıt olarak alır (bkz. PLAN.md §4.4).

## 3. Kaynak eşlemesi (mobil)

| FHIR | Mobil tablo | Okunan / yazılan alanlar |
|---|---|---|
| `Encounter` | `encounters` | `period.start`, `participant[0].individual.display`, `serviceProvider.display` (gidilen hastane/klinik; okurken `location[0].location.display` de kabul edilir), `reasonCode[].text`, eklentiler: `encounter-findings`, `encounter-plan`, `encounter-note` (hastanın kendi notu) (`valueString`). Kullanıcının girdiği doktor ziyaretleri `meta.tag` = `patient-reported` taşır |
| `Condition` + `encounter-diagnosis` | `diagnoses` | `code` (aşağıya bakın), `verificationStatus` (`provisional` / `confirmed`), `encounter`, `recordedDate` |
| `Condition` (diğer) | `conditions` | `code` (aşağıya bakın), `onsetDateTime`, `abatementDateTime`, `clinicalStatus`, `note` |
| `AllergyIntolerance` | `allergies` | `code` (ATC ya da metin), `reaction[].manifestation[].text`, `criticality` |
| `MedicationRequest` | `medications` | `medicationCodeableConcept` (ATC), `dosageInstruction[0]`: `text`, `doseAndRate[0].doseQuantity`, `timing.repeat.timeOfDay`, `boundsPeriod` / `boundsDuration`; `authoredOn`, `status`, `groupIdentifier`, `encounter` (ilacın yazıldığı muayene; yalnızca muayene aynı paketteyse yazılır) |
| `Immunization` | `immunizations` | `vaccineCode`, `occurrenceDateTime`, `protocolApplied[0].doseNumberPositiveInt`, `lotNumber`, `primarySource` |
| `ImmunizationRecommendation` | `immunization_due` | her `recommendation`: `vaccineCode[0]`, `dateCriterion[0].value` (`30980-7`), `doseNumberPositiveInt`, `forecastStatus` |
| `Observation` | `observations` | LOINC `code`, `valueQuantity` (UCUM), tansiyon `component` (`8480-6` / `8462-4`), `effectiveDateTime` |
| `Appointment` | `appointments` | `start`, `description`, `participant[].actor.display`; `cancelled` atlanır |

### Hastalık ve tanı kodları

Kodlama **ICD-11 MMS**'tir (gerekçe: [TERMINOLOJI.md](TERMINOLOJI.md) §3).
Mobil uygulama kodu **ve kod sistemini** birlikte saklar (`conditions.code` +
`conditions.code_system`, aynısı `diagnoses`'te), bu yüzden dışarıdan gelen
kodlar kaybolmadan geri yazılabilir.

**Yazarken** (`Condition.code`):

| Alan | Değer |
|---|---|
| `coding[0].system` | Kayıttaki kod sistemi; kullanıcı katalogdan seçtiyse `http://id.who.int/icd/release/11/mms` |
| `coding[0].code` | ICD-11 MMS kodu, ör. `BA00`, `5A11`, `FA80.9` |
| `coding[0].display` | Terminoloji paketindeki resmî Türkçe ad (paket yüklenemezse yazılmaz) |
| `coding[1]` | WHO eşleme tablosundaki ICD-10 karşılığı, ör. `I10` — yalnızca eşleme tek bir koda düşerse. Aralık (`J09-J18`) ya da bölüm (`IX`) ICD-10 kodu değildir, yazılmaz |
| `text` | Kullanıcının / hekimin yazdığı ad. Kullanıcı adı elle değiştirirse kod düşer ve yalnızca `text` kalır |

ICD-10 karşılığı, ICD-10 ile çalışan kurumlar paketi okuyabilsin diye eklenir;
asıl kod her zaman `coding[0]`'dır.

**Okurken** kodlamalar şu sırayla denenir: ICD-11 MMS → ICD-10
(`http://hl7.org/fhir/sid/icd-10`) → ICD-10-CM → paketteki ilk kodlama.
Seçilen kodlamanın `system`'i de saklanır; tanınmayan bir sistem (ör. kurumun
kendi kod listesi) reddedilmez, olduğu gibi durur ve uygulamada kod yanında
sistem adı yerine kodun kendisi gösterilir. Ham FHIR JSON ayrıca
`fhir_resources`'ta saklandığı için hiçbir kodlama kaybolmaz.

**Kodsuz kayıtlar:** kullanıcı listeden seçmeden kendi yazdığı hastalık kodsuz
kalır; paket yenilendiğinde adı katalogda birebir ve tek bir kategoriye
eşleşiyorsa kod bir kez kendiliğinden yazılır. Klinikten gelen kodsuz
kayıtlara dokunulmaz.

**Hastalığın durumu:** mobil `clinicalStatus`'u `active` ya da `resolved` yazar; geçirilmiş hastalıkta bitiş tarihi `abatementDateTime`'dır. Okurken `inactive` ve `resolved` geçirilmiş, diğer değerler (`remission` dahil) devam eden sayılır. `clinicalStatus` yoksa `abatementDateTime` varlığına bakılır.

Eklenti adresleri: `https://github.com/cengizonkal/lokman/fhir/StructureDefinition/<ad>`.

Bilinmeyen kaynak türleri ve zorunlu alanı eksik kaynaklar atlanır, kullanıcıya sayısı gösterilmez. Katalogda olmayan kodlar reddedilmez; kod **ve kod sistemi** olduğu gibi saklanır.

**Dışa aktarılmayanlar:** ilaç “aldım / atladım” kayıtları (`dose_events`) hiçbir pakete girmez.

## 4. Açık konular

- [ ] Paketlerin CI'da HL7 FHIR Validator (IPS profili) ile doğrulanması
- [ ] İçe aktarımda ICD-10 kodlu kayda ICD-11 karşılığının kullanıcıya önerilmesi (eşleme tablosu pakette var, ekran yok)
- [ ] Alerji (ATC / SNOMED) ve aşı (SNOMED GPS) kodlarının terminoloji paketinden gelmesi
- [ ] Kimlik no (`NI`) identifier sistemlerinin ülkeye göre adresleri (TR / KKTC)
- [ ] Mobil kayıtlarda `Organization` kaynağı üretilmesi (şimdilik kurum adı `meta.tag.display`'de)
