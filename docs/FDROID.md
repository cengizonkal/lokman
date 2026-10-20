# F-Droid'de yayın

Lokman mobil uygulaması, Android'in özgür yazılım deposu
[F-Droid](https://f-droid.org/)'de yayınlanır. F-Droid mağazaya yüklenen bir APK
kabul etmez: tarifi `fdroiddata` deposunda tutulan uygulamayı **kaynaktan kendi
sunucusunda derler**, derlerken kapalı kaynak bağımlılık arar ve sonucu kendi
anahtarıyla imzalayıp yayınlar.

## 1. Karar: imzayı F-Droid atar

F-Droid'in derlediği APK, GitHub Releases'teki APK ile **aynı imzayı taşımaz**.
Android bir uygulamanın güncellemesini yalnızca aynı anahtarla imzalanmışsa kabul
ettiği için bunun sonuçları şunlardır:

- İki kanal birbirinden bağımsızdır. F-Droid'den kuran F-Droid'den, GitHub'dan
  kuran GitHub'dan güncelleme alır.
- Kanal değiştiren kullanıcı uygulamayı **kaldırıp yeniden kurmak** zorundadır ve
  telefondaki veriler silinir. Önce **Paylaş → Paylaş / yedekle** ile sağlık
  dosyası alınmalı, kurduktan sonra içe aktarılmalıdır. Sürüm notlarında ve
  README'de bu uyarı yazılı olmalıdır.
- **Bu karar geri alınamaz.** Uygulama bir kez F-Droid anahtarıyla yayınlandıktan
  sonra "yinelenebilir derleme"ye (aşağıya bakın) geçmek, F-Droid'deki
  kullanıcıları da uygulamayı kaldırmaya zorlar.

Seçilmeyen yol — **yinelenebilir derleme** (reproducible build): F-Droid kaynaktan
derler, çıkan APK'yı GitHub'daki imzalı APK ile bit bit karşılaştırır ve eşleşirse
*bizim imzaladığımız* APK'yı yayınlar (`Binaries:` + `AllowedAPKSigningKeys:`
alanları). Tek imza olurdu, ama Flutter'da derleme ortamının (Flutter sürümü,
JDK, NDK, derleme yolu) birebir eşlenmesi gerekir ve doğrulama tutmadığı sürümde
F-Droid hiçbir şey yayınlamaz. Kullanıcı sayısı küçükken standart yol seçildi.

## 2. Ön koşullar

F-Droid'in [kabul ölçütleri](https://f-droid.org/docs/Inclusion_Policy/) açısından
durum:

| Koşul | Durum |
|---|---|
| Kaynak kodu herkese açık, FLOSS lisansı | MIT, `LICENSE` |
| Kapalı kaynak bağımlılık yok | ✔ Google Play Services / Firebase / ML Kit yok. QR için `mobile_scanner` (ML Kit) yerine **`flutter_zxing`** (zxing-cpp, Apache-2.0) kullanılıyor; kamera `camera` + CameraX ile |
| İzleme / reklam yok | ✔ Hesap, sunucu, analitik yok; tek ağ erişimi QR'daki `https://` bağlantısından dosya indirmek |
| Her sürümün etiketi var | ✔ `v<sürüm>`, sürüm iş akışı oluşturuyor |
| Benzersiz uygulama kimliği | ✔ `io.github.cengizonkal.lokman` |
| En az 3 aydır geliştiriliyor | ⚠ Depo 18 Ekim 2026'da açıldı; bu koşul henüz sağlanmıyor (aşağıya bakın) |

**İncelemede çıkabilecek konular:**

1. **ICD-11 varlıkları.** `mobile/assets/terminology/` altındaki WHO ICD-11 MMS
   verisi CC BY-ND 3.0 IGO lisanslıdır; kod değil veridir ve değiştirilmemiştir
   (bkz. [TERMINOLOJI.md](TERMINOLOJI.md), `terminology/LICENSES.md`). F-Droid
   varlıklarda esneklik tanır ama bu veri için `NonFreeAssets`
   [karşı-özelliğini](https://f-droid.org/docs/Anti-Features/) ekleyebilir.
   Gönderirken durumu kendimiz yazmak en iyisi: veri WHO'nun izin verdiği
   biçimde yeniden dağıtılıyor, atıf hem `LISANS.txt`'te hem uygulama içindeki
   lisans ekranında.
2. **Projenin yaşı.** Kabul ölçütlerinde "uygulama en az 3 aydır etkin
   geliştiriliyor olmalı" maddesi var. Lokman'ın ilk commit'i 18 Ekim 2026.
   Gönderim bugün yapılırsa paketleyiciler beklememizi isteyebilir; tarif ve
   üstveri hazır olduğu için gönderimi Ocak 2027'ye bırakıp bu arada sürüm
   yayınlamayı sürdürmek daha az sürtünmeli yoldur. Erken denemenin zararı da
   yok: MR açık kalır ya da kapanır, depoya bir şey olmaz.

## 3. Depodaki dosyalar

```
mobile/fastlane/metadata/android/
├── tr-TR/, en-US/
│   ├── title.txt              (≤ 50 karakter)
│   ├── short_description.txt  (≤ 80, nokta ile bitmez)
│   ├── full_description.txt   (≤ 4000)
│   └── changelogs/<derleme numarası>.txt   (≤ 500, ör. 5.txt)
└── en-US/images/
    ├── icon.png (512×512), featureGraphic.png (1024×500)   ← render_icons.py üretir
    └── phoneScreenshots/1.png, 2.png, …                    ← elle çekilir
mobile/fastlane/check_metadata.py   sınırları denetler (CI çalıştırır)
mobile/fdroid/io.github.cengizonkal.lokman.yml   F-Droid derleme tarifi
```

Görseller yalnızca `en-US` altındadır: F-Droid istemcisi bir dilde görsel
bulamazsa `en-US`'e düşer, böylece ekran görüntüleri tek yerde durur. Metinler
iki dilde.

**Önemli:** F-Droid üstveriyi **yalnızca derlediği sürümün commit'inden** okur.
`fastlane/` klasörü bir sürüm etiketinde yoksa o sürümün sayfası boş görünür.

### Ekran görüntüleri

Listelemede yedi görüntü var (`…/phoneScreenshots/1.png` … `7.png`): Bugün,
İlaçlar, ICD-11 araması, ölçüm grafiği, Kayıtlar, Paylaş, aile profilleri.
1080×2400; Android emülatöründe, **Ayarlar → Örnek klinik dosyasını dene** ile
gelen "Ayşe Şahin" örnek profiliyle çekildi — gerçek kişi verisi yok. Ölçüm
grafiğindeki altı aylık geçmiş için, örnek dosyadan türetilmiş daha çok ölçüm
içeren bir paket aktarıldı (depoda tutulmuyor).

Yenilemek gerekirse:

```bash
emulator -avd <avd> -no-window -gpu swiftshader_indirect &
adb install -r build/app/outputs/flutter-apk/app-x86_64-release.apk
# durum çubuğunu sabitle: saat 10:00, pil dolu, bildirim simgesi yok
adb shell settings put global sysui_demo_allowed 1
adb shell am broadcast -a com.android.systemui.demo -e command enter
adb shell am broadcast -a com.android.systemui.demo -e command clock -e hhmm 1000
adb shell am broadcast -a com.android.systemui.demo -e command battery -e level 100 -e plugged false
adb shell am broadcast -a com.android.systemui.demo -e command notifications -e visible false
adb exec-out screencap -p > fastlane/metadata/android/en-US/images/phoneScreenshots/1.png
optipng -o2 fastlane/metadata/android/en-US/images/phoneScreenshots/*.png
```

Emülatör x86_64 olduğu için kurulan APK da x86_64 olmalı
(`flutter build apk --release --split-per-abi`). `adb shell input text` yalnızca
ASCII yazabilir; Türkçe karakter gereken bir alan varsa ekran klavyesinden
yazın (ICD-11 araması ASCII yazımla da bulur: "kalp krizi" → *Akut miyokard
enfarktüsü*).

## 4. Derleme tarifi

`mobile/fdroid/io.github.cengizonkal.lokman.yml`, `fdroiddata` deposuna
`metadata/io.github.cengizonkal.lokman.yml` olarak gidecek dosyanın kopyasıdır.
Satırların nedeni:

- `subdir: mobile` — Flutter projesi (yani `pubspec.yaml`) depo kökünde değil.
  `prebuild` ve `build` komutları bu klasörde çalışır; `output` da ona göredir.
- `srclibs: flutter@3.47.7` — F-Droid Flutter'ı bu etiketten çeker; depodaki CI
  iş akışlarıyla aynı sürüm olmalıdır.
- `ndk: r28c` — Flutter 3.47.7'nin beklediği NDK (28.2.13676358). `flutter_zxing`
  zxing-cpp'yi CMake ile kaynaktan derlediği için NDK şart.
- `echo "flutter.sdk=…" > android/local.properties` — `settings.gradle.kts` bu
  dosyayı zorunlu tutuyor.
- `PUB_CACHE=$(pwd)/.pub-cache` — pub paketleri depo içine inerse F-Droid'in
  tarayıcısı onları da tarar; `scandelete` derlemeden sonra siler.
- `pub get --enforce-lockfile` — `pubspec.lock` ne diyorsa o sürümler kurulur.
- Tarif JDK kurmuyor: F-Droid sunucusunun varsayılan Java'sı kullanılıyor.
  Gradle 9.3.1 + AGP 9.1 en az JDK 17 ister (CI de 17 kullanır) ve çok yeni
  Java sürümleriyle (27) çalışmaz. `fdroid build` "Gradle version is
  incompatible with the Java version" derse tarifin başına
  `sudo: [apt-get update, apt-get install -y openjdk-21-jdk-headless,
  update-java-alternatives -a]` eklenir.
- `--split-per-abi` ve üç derleme bloğu — tek evrensel APK 85 MB oluyor (üç
  mimarinin Flutter motoru, zxing ve sqlite kitaplıkları). Bölününce
  armeabi-v7a 28 MB, arm64-v8a 30 MB, x86_64 32 MB; kullanıcı yalnızca kendi
  mimarisininkini indirir. F-Droid'in Flutter şablonu da bunu öneriyor.
  GitHub Releases'teki APK evrensel kalır.
- `VercodeOperation` — bölünmüş APK'larda derleme numarasını Flutter'ın kendisi
  değiştirir: armeabi-v7a `1000 + kod`, arm64-v8a `2000 + kod`, x86_64
  `4000 + kod` (yerelde doğrulandı: 0.1.3+4 → 1004 / 2004 / 4004). Tarifteki
  numaralar APK'nın içindekiyle birebir aynı olmak zorunda; `VercodeOperation`
  yeni sürümlerde aynı hesabı yapar, `CurrentVersionCode` en büyüğüdür.
- `UpdateCheckMode: Tags` + `UpdateCheckData` — sürüm `mobile/pubspec.yaml`
  içinde (`0.1.4+5` → `versionName` 0.1.4, `versionCode` 5); F-Droid yeni etiketi
  görünce üç derleme bloğunu kendisi ekler.

## 5. İlk gönderim

1. Yayınlanacak sürümü hazırla: `fastlane/` metinleri güncel, `changelogs/<kod>.txt`
   yazılmış, ekran görüntüleri eklenmiş olmalı. Sonra `mobile/pubspec.yaml`'da
   sürümü artır, `mobile/CHANGELOG.md`'ye not ekle, push et — iş akışı `v<sürüm>`
   etiketini ve GitHub sürümünü oluşturur.
2. Tarifteki `versionName`, üç bloğun `versionCode`'u (`1000/2000/4000 + derleme
   numarası`), `CurrentVersion` ve `CurrentVersionCode` o sürüme eşitlenir.
   `commit:` alanına etiketin tam hash'i yazılır (`git rev-list -n1 v0.1.4`);
   F-Droid etiket adı yerine hash ister.
3. [gitlab.com/fdroid/fdroiddata](https://gitlab.com/fdroid/fdroiddata) çatallanır,
   uygulama kimliğiyle dal açılır:
   ```bash
   git clone git@gitlab.com:<kullanıcı>/fdroiddata.git && cd fdroiddata
   git checkout -b io.github.cengizonkal.lokman
   cp ~/projects/lokman/mobile/fdroid/io.github.cengizonkal.lokman.yml metadata/
   ```
4. Denenir (fdroidserver kurulu olmalı):
   ```bash
   fdroid readmeta && fdroid lint io.github.cengizonkal.lokman
   fdroid checkupdates --allow-dirty io.github.cengizonkal.lokman
   fdroid build io.github.cengizonkal.lokman        # buildserver kapsayıcısında
   ```
   `scandelete: mobile/.pub-cache` yolunu tarayıcı bulamazsa `.pub-cache` olarak
   dener (yol, deponun kökünden sayılır).
5. `git commit -m "New App: io.github.cengizonkal.lokman"` ve **New App**
   etiketiyle merge request açılır. MR açıklamasında yazılacaklar: uygulamanın ne
   olduğu, sunucu/hesap/izleme olmadığı, geliştiricinin kendisi gönderdiği, ICD-11
   verisinin lisansı (yukarıdaki 1. madde).
6. Paketleyiciler MR'ı inceler; birleştikten sonra uygulama ~24-48 saat içinde
   mağazada görünür.

MR açıklaması olarak (İngilizce) şu metin kullanılabilir:

```text
Lokman is an open source personal health record for Android: medicines with
reminders, vaccinations, conditions, allergies, measurements and appointments,
all kept on the phone. There is no account and no server; the app's only network
access is downloading the user's own health file from the https URL encoded in a
QR code shown at a clinic. Records are exchanged with clinics as HL7 FHIR R4
(IPS) files.

* Source: https://github.com/cengizonkal/lokman (MIT). I am the developer and I
  am submitting the app myself.
* The Flutter app lives in the repository's `mobile/` subdirectory; fastlane
  metadata is in `mobile/fastlane/metadata/android/` (tr-TR, en-US).
* No proprietary dependencies: QR scanning uses flutter_zxing (zxing-cpp,
  Apache-2.0) with the camera plugin. There are no Google Play Services,
  Firebase or ML Kit dependencies, and no analytics or ads.
* Bundled data: `mobile/assets/terminology/` holds disease codes and titles
  generated from the WHO ICD-11 MMS release and redistributed unmodified under
  CC BY-ND 3.0 IGO, with attribution in the bundled LISANS.txt and on the app's
  licence screen (see terminology/LICENSES.md). Please tell me if you would
  rather have the NonFreeAssets anti-feature set for it.
* The recipe builds one APK per ABI (--split-per-abi), since the universal APK
  is 85 MB; the zxing native library is built from source by the NDK.
```

Birleştikten sonra `fdroiddata`'daki kopya asıl kaynaktır: `AutoUpdateMode: Version`
sayesinde yeni etiketler için derleme bloklarını F-Droid kendisi ekler. Depodaki
kopya yalnızca ilk gönderim ve tarif değişiklikleri için tutulur; tarif
değişikliği gerekirse aynı yolla yeni bir MR gönderilir.

## 6. Her sürümde

- [ ] `fastlane/metadata/android/<dil>/changelogs/<yeni derleme numarası>.txt`
      (≤ 500 karakter, iki dilde) — `flutter test` gibi CI de denetler.
- [ ] Metinlerde değişiklik varsa `full_description.txt` güncellenir.
- [ ] Ekran görüntüleri eskidiyse yenilenir.
- [ ] Sürüm etiketi push edilir; F-Droid etiketi kendi görür, bir hafta içinde
      derleyip yayınlar. Elle bir şey yapılmaz.
