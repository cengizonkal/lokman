# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project shape

Lokman is an open-source patient tracking system for private clinics, made of **two independent products** that share no database, API or auth:

- `mobile/` — Flutter/Android app, the patient's personal health record. **This is the only code that exists today** (v0.1 shipped).
- `backend/` — Laravel + Filament + PostgreSQL clinic system. **Not started.** Planned in `docs/PLAN.md` §2 and `docs/VERITABANI.md` §1–5.

- `terminology/` — the **Lokman Terminology Package** builder: `build.py` turns WHO ICD-11 MMS release files into the assets committed under `mobile/assets/terminology/` (both products are meant to consume the same package; only mobile does today).

The only link between the two products is **HL7 FHIR R4 (IPS-compliant) JSON**, exchanged by QR link or file. `fhir/examples/` holds the shared contract fixtures that both sides' tests consume.

## Language conventions

- **Code identifiers, table and column names: English.** Everything user-facing is **Turkish**: UI strings, doc comments, `docs/*.md`, `CHANGELOG.md`, commit messages.
- Commit messages are Turkish, imperative-ish, often prefixed with the area (`Mobil: geçirilmiş hastalıklar`, `Logo: ...`, `Belgeler: ...`).
- Target markets are Turkey and Northern Cyprus (KKTC); no dependency on Turkish national systems (e-Nabız / e-Reçete) is allowed in the design.

## Docs are the decision record

`docs/` is not background reading — it is the spec, and it is kept in sync with code by hand:

- `docs/PLAN.md` — architecture decisions, role/permission matrix, phased work plan (F0–F5) with checkboxes. Tick boxes when a phase item lands.
- `docs/VERITABANI.md` — both databases' schema design (PostgreSQL §1–5, mobile SQLite §6).
- `docs/fhir-sozlesmesi.md` — the field-by-field FHIR contract: Composition sections, identifier systems, origin-ref rules, resource mapping. **Any change to `mobile/lib/fhir/` must be reflected here**, because the unwritten backend will be built against this document.
- `docs/TERMINOLOJI.md` — terminology package decisions (ICD-11 for diagnoses, ATC, LOINC/UCUM, SNOMED GPS) and the license research behind them. ICD-11 was chosen over ICD-10 specifically because its license permits redistribution inside an MIT-licensed app. The ICD-11 half is now built and shipped; `terminology/README.md` documents the package itself and `terminology/LICENSES.md` carries the attribution WHO's CC BY-ND licence requires (the app shows it via `LicenseRegistry`).

## Mobile app

### Commands (run from `mobile/`)

Requires Flutter 3.47.7 (Dart 3.13), JDK 17, Android SDK — the version is pinned in both CI workflows.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after any change to lib/data/db/tables.dart
dart format lib test                                        # CI fails on unformatted code
flutter analyze
flutter test
flutter test test/fhir_import_test.dart                     # one file
flutter test test/fhir_import_test.dart --plain-name 'ad'   # one test by name
flutter run
flutter build apk --release
python3 branding/render_icons.py                            # regenerate logo SVG + launcher PNGs
python3 ../terminology/build.py                             # regenerate the terminology assets
python3 ../terminology/build.py --check                     # are the committed assets current? (CI)
```

### Terminology package

`mobile/assets/terminology/` is **generated, committed and never hand-edited**:
`icd11-mms-<release>.tsv` (17k ICD-11 MMS categories with Turkish titles,
project-written colloquial synonyms and the ICD-10 equivalent),
`icd10-icd11-<release>.tsv` (WHO mapping) and `LISANS.txt` (attribution shown
in the app). `mobile/lib/domain/terminology/icd11.dart` reads them: search
is tiered (exact → prefix → word start → substring) over a pre-normalized
column, so **the Turkish folding table in `icd11.dart` and the `FOLD` map in
`terminology/build.py` must stay identical**. Bumping the ICD-11 release means
changing `RELEASE` in `build.py` and `Icd11Asset.release` in `icd11.dart`
together — the build fails if they disagree.

Conditions and diagnoses store `code` **plus `codeSystem`** (the FHIR
`coding.system` URI), so an imported code from any system round-trips
unchanged; `docs/fhir-sozlesmesi.md` §3 "Hastalık ve tanı kodları" is the
contract.

CI (`.github/workflows/mobile-ci.yml`) additionally runs `build_runner` and then `git diff --exit-code -- lib`: **`database.g.dart` is committed and must match the tables**.

### Layers

```
main.dart          opens AppDatabase, builds Repository + NotificationService,
                   decides `onboarded` (= any profile exists), overrides providers,
                   then re-schedules all notifications from current records
app/providers.dart the whole provider graph; databaseProvider is a throwing stub
                   that main() and tests override
data/db/           drift tables (tables.dart) + generated database.g.dart
data/repository.dart  the ONLY data access layer — screens never touch AppDatabase
                   directly (ExportData.load and Importer are the exceptions, via repo.db)
domain/            pure logic: dose scheduling (dose_schedule.dart), observation
                   types as LOINC/UCUM catalog (catalog.dart)
fhir/              bundle_reader (parse), bundle_writer (build), importer (match
                   profile + upsert), fhir_common (systems, date helpers)
notifications/     planner.dart is pure (records -> List<PlannedNotification>);
                   notification_service.dart is the device side and no-ops off Android
pdf/               bilingual TR/EN printable summary
features/          screens, one folder per bottom-nav area
```

State is Riverpod; data flows as drift `watch*` streams exposed through `StreamProvider.family<_, profileId>`. The selected profile lives in the `app_settings` key-value table (`SettingKeys.currentProfile`), read via `currentProfileProvider`, which falls back to the first profile. Routing is `go_router` with a `StatefulShellRoute.indexedStack` for the four tabs.

### Record provenance and idempotent import

Every health record table mixes in `RecordColumns`, which carries the rules the whole app depends on:

- `source` is `RecordSource.clinic` or `RecordSource.self`. Clinic-sourced records are shown with the institution name (`originName`) and are **read-only in the UI**; self-entered records are editable.
- `originRef` is the record's identity in the source system (`<source>|<Type>/<id>`) and is **unique**. Re-importing the same bundle updates rows instead of duplicating them — this is covered by tests and is a stated product guarantee.
- Raw FHIR JSON of every imported resource is kept in `fhir_resources` so nothing is lost on round-trip.
- `dose_events` (taken/skipped) deliberately has no `RecordColumns` and is **never exported** — see `ExportData`.

Profile matching on import (`Importer.match`) first looks for a known `Patient.identifier` (own app system or a row in `profile_links`), and only otherwise scores candidates on Turkish-normalized name + birth date.

### Schema changes

Bump `schemaVersion` in `lib/data/db/database.dart`, add the step to `onUpgrade`, re-run `build_runner`, and extend `test/migration_test.dart`, which builds an old-schema file by dropping columns and asserts the upgrade preserves rows. `PRAGMA foreign_keys = ON` is set in `beforeOpen`; `newId()` is UUIDv7 so ids sort by time.

### Tests

`test/test_utils.dart` gives `memoryDb()` / `memoryRepo()` and `exampleBundle()`, which walks up from the CWD to read `fhir/examples/`. Widget tests use `pumpApp` in `test/app_test.dart`, which sets a phone-sized view and injects `NotificationService(enabled: false)`; they must tear down with `tearDownApp` so drift's stream timers stop.

`mobile/assets/examples/klinik-cikti-ayse.json` is a **copy** of `fhir/examples/klinik-cikti-ayse.json` (the app bundles it for the "try a sample clinic file" path). `test/example_asset_test.dart` fails if they diverge — edit the one under `fhir/` and copy it over.

### Releasing

`.github/workflows/mobile-release.yml` publishes a GitHub release whenever `pubspec.yaml`'s version has no matching `v<name>` tag. To release: bump `version` in `pubspec.yaml` (both name and build number, e.g. `0.1.1+2`), add a `## <version>` section to `mobile/CHANGELOG.md` (its body becomes the release notes), push. A version containing `-` is published as a pre-release.

Signing: release APKs are signed from `android/key.properties` (git-ignored locally, generated in CI from the `ANDROID_KEYSTORE_*` secrets). Without the secret the workflow falls back to the debug key and adds a warning to the notes. **The signing key must never change** — Android would otherwise force users to uninstall, wiping all on-device data.

## Privacy constraints to respect

The mobile app has no account and no server: it never makes outbound requests except downloading a QR-provided bundle, and only `https://` QR URLs are accepted. There is no in-app encryption or app lock by design (Android app sandbox + screen lock). Data stays on the phone; the user's only backup is a full FHIR export.
