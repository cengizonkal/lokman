# Lokman mobil uygulaması

Ailenin kişisel sağlık defteri (Flutter, Android). Veriler yalnızca telefonda durur; hesap ya da sunucu yoktur. Klinikten gelen kayıtlar **FHIR R4 (IPS)** sağlık dosyasıyla (QR ya da dosya) aktarılır.

## Telefona kurulum

1. [GitHub Releases](https://github.com/cengizonkal/lokman/releases) sayfasından en son `lokman-<sürüm>.apk` dosyasını telefona indirin.
2. Dosyayı açın. Telefon izin isterse **Bu kaynaktan yüklemeye izin ver** seçeneğini açın.
3. **Yükle**'ye dokunun. Android 7.0 ve üzeri desteklenir.

İlk açılışta kimin için kullanacağınızı (yalnızca ad zorunlu) ve bildirim iznini sorar. Klinik sistemi olmadan aktarımı denemek için **Ayarlar → Örnek klinik dosyasını dene**.

## Neler var (v0.1)

| Sekme | İçerik |
|---|---|
| **Bugün** | Günün ilaç dozları (Aldım / Atladım), yaklaşan aşı ve randevular, son ölçümler, yedek hatırlatması |
| **İlaçlar** | 4 adımlı ilaç ekleme (ad → doz → saatler → süre), saat bildirimleri, düzenli kullanım oranı |
| **Kayıtlar** | Aşılar (yapılan + yapılacak), alerjiler, hastalıklar (devam eden + geçirilmiş), ölçümler (grafikli), randevular, muayeneler |
| **Paylaş** | QR okut / dosya seç ile içe aktarım; sağlık dosyası (.json) + PDF özet ile paylaşım ve yedek |

Üst çubuktaki profil düğmesiyle aile üyeleri arasında geçilir. Klinikten gelen kayıtlar kurum adıyla etiketlenir ve değiştirilemez; kullanıcının girdikleri “Kendi girdiğim” olarak görünür.

## Geliştirme

Gerekenler: Flutter 3.47.7 (Dart 3.13), JDK 17, Android SDK.

```bash
cd mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # drift tabloları değişince
flutter analyze
flutter test
flutter run            # bağlı telefon / emülatör
flutter build apk --release
```

Klasörler:

```
lib/
  app/            tema, yönlendirme, Riverpod sağlayıcıları, biçimlendirme
  data/           drift veritabanı (db/) ve Repository
  domain/         doz takvimi, ölçüm türleri ve öneri listeleri
  fhir/           FHIR Bundle okuma / yazma, içe aktarım ve profil eşleştirme
  pdf/            iki dilli PDF özet
  notifications/  bildirim planı (saf mantık) ve cihaz zamanlayıcısı
  features/       ekranlar
test/             birim ve arayüz testleri (örnek paket: ../fhir/examples)
```

`assets/examples/klinik-cikti-ayse.json`, `fhir/examples/` altındaki örneğin kopyasıdır; bir test ikisinin aynı kaldığını denetler.

## Sürüm yayını

`.github/workflows/mobile-release.yml`, `pubspec.yaml`'daki sürüm (ör. `0.1.0+1`) için `v0.1.0` etiketi yoksa testleri çalıştırır, APK'yı derler ve GitHub Releases'te yayınlar. Yeni sürüm için:

1. `pubspec.yaml`'da `version`'ı artırın (`0.1.1+2`: ad ve derleme numarası birlikte).
2. `CHANGELOG.md`'ye `## 0.1.1` başlığıyla notları yazın.
3. Push edin. Tire içeren sürümler (`0.2.0-beta.1`) ön sürüm olarak yayınlanır.

### İmza anahtarı (bir kez, önemli)

Android, bir uygulamanın güncellemesini yalnızca **aynı anahtarla** imzalanmışsa kabul eder. Anahtar değişirse kullanıcı uygulamayı kaldırıp yeniden kurmak zorunda kalır ve **telefondaki tüm veriler silinir**. Bu yüzden kalıcı bir anahtar oluşturup GitHub secret'larına ekleyin; secret yoksa iş akışı test (debug) anahtarıyla imzalar ve sürüm notuna uyarı yazar.

```bash
keytool -genkey -v -keystore lokman-upload.jks -storetype JKS \
  -keyalg RSA -keysize 4096 -validity 10000 -alias lokman
base64 -w0 lokman-upload.jks > lokman-upload.jks.b64
```

Depo → **Settings → Secrets and variables → Actions → New repository secret**:

| Secret | Değer |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | `lokman-upload.jks.b64` dosyasının içeriği |
| `ANDROID_KEYSTORE_PASSWORD` | keystore şifresi |
| `ANDROID_KEY_ALIAS` | `lokman` |
| `ANDROID_KEY_PASSWORD` | anahtar şifresi (keystore şifresiyle aynıysa boş bırakılabilir) |

`lokman-upload.jks` dosyasını ve şifreleri güvenli bir yerde yedekleyin; kaybolursa güncelleme yayınlanamaz. Yerelde imzalı derleme için `android/key.properties` (git'e girmez):

```properties
storeFile=/tam/yol/lokman-upload.jks
storePassword=...
keyAlias=lokman
keyPassword=...
```
