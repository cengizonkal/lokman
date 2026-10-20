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
| `Encounter` | `encounters` | `period.start`, `participant[0].individual.display`, `reasonCode[].text`, eklentiler: `encounter-findings`, `encounter-plan` (`valueString`) |
| `Condition` + `encounter-diagnosis` | `diagnoses` | `code` (ICD-11: `http://id.who.int/icd/release/11/mms`; eşleme lisansı uygunsa ek ICD-10 coding), `verificationStatus` (`provisional` / `confirmed`), `encounter`, `recordedDate` |
| `Condition` (diğer) | `conditions` | `code`, `onsetDateTime`, `abatementDateTime`, `clinicalStatus`, `note` |
| `AllergyIntolerance` | `allergies` | `code` (ATC ya da metin), `reaction[].manifestation[].text`, `criticality` |
| `MedicationRequest` | `medications` | `medicationCodeableConcept` (ATC), `dosageInstruction[0]`: `text`, `doseAndRate[0].doseQuantity`, `timing.repeat.timeOfDay`, `boundsPeriod` / `boundsDuration`; `authoredOn`, `status`, `groupIdentifier` |
| `Immunization` | `immunizations` | `vaccineCode`, `occurrenceDateTime`, `protocolApplied[0].doseNumberPositiveInt`, `lotNumber`, `primarySource` |
| `ImmunizationRecommendation` | `immunization_due` | her `recommendation`: `vaccineCode[0]`, `dateCriterion[0].value` (`30980-7`), `doseNumberPositiveInt`, `forecastStatus` |
| `Observation` | `observations` | LOINC `code`, `valueQuantity` (UCUM), tansiyon `component` (`8480-6` / `8462-4`), `effectiveDateTime` |
| `Appointment` | `appointments` | `start`, `description`, `participant[].actor.display`; `cancelled` atlanır |

**Hastalığın durumu:** mobil `clinicalStatus`'u `active` ya da `resolved` yazar; geçirilmiş hastalıkta bitiş tarihi `abatementDateTime`'dır. Okurken `inactive` ve `resolved` geçirilmiş, diğer değerler (`remission` dahil) devam eden sayılır. `clinicalStatus` yoksa `abatementDateTime` varlığına bakılır.

Eklenti adresleri: `https://github.com/cengizonkal/lokman/fhir/StructureDefinition/<ad>`.

Bilinmeyen kaynak türleri ve zorunlu alanı eksik kaynaklar atlanır, kullanıcıya sayısı gösterilmez. Katalogda olmayan kodlar reddedilmez; kod olduğu gibi saklanır.

**Dışa aktarılmayanlar:** ilaç “aldım / atladım” kayıtları (`dose_events`) hiçbir pakete girmez.

## 4. Açık konular

- [ ] Paketlerin CI'da HL7 FHIR Validator (IPS profili) ile doğrulanması
- [ ] Kimlik no (`NI`) identifier sistemlerinin ülkeye göre adresleri (TR / KKTC)
- [ ] Mobil kayıtlarda `Organization` kaynağı üretilmesi (şimdilik kurum adı `meta.tag.display`'de)
