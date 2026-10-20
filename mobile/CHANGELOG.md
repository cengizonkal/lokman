# Değişiklikler

## 0.1.3

- **Hastalık ve tanı adları artık uluslararası standart kodla kaydediliyor.** Hastalık ya da tanı yazarken uygulama, içinde gömülü gelen **ICD-11** listesinde arama yapar (17.231 hastalık, resmî Türkçe adlarıyla). Günlük dille yazmanız yeter: "yüksek tansiyon" yazınca *Esansiyel Hipertansiyon*, "zatürre" yazınca *Pnömoni*, "şeker hastalığı" yazınca *Tip 2 diabetes mellitus* önerilir. Listeden seçerseniz hastalığın kodu da kaydedilir ve alanın altında görünür ("ICD-11 BA00").
- Listede olmayan bir şey yazmaya devam edebilirsiniz; kayıt yine tutulur, yalnızca kodu olmaz. Adı sonradan elle değiştirirseniz kod düşer, çünkü kod artık o adı göstermiyordur.
- **Sağlık dosyanız artık daha standart:** dışa aktarılan dosyada hastalık ve tanılar ICD-11 koduyla, resmî adıyla ve (varsa) ICD-10 karşılığıyla yazılır. Böylece dosyayı okuyan klinik, ICD-10 kullanıyor olsa bile kaydı tanır. Doktorunuz ICD-10 kodunu (ör. `I10`) yazarak da arayabilir.
- Klinikten gelen dosyalarda kodun hangi listeden geldiği de saklanır: ICD-11, ICD-10 ya da kurumun kendi listesi; tanınmayan kod artık kaybolmaz ve geri aktarımda aynen çıkar.
- Daha önce kendi girdiğiniz hastalıklardan adı listeye birebir uyanlara kod bir kez kendiliğinden işlenir. Klinikten gelen kayıtlara dokunulmaz.
- Bir kaydı düzenleyip bir alanı tamamen boşalttığınızda (not, hastane adı, tanı) eski değerin kayıtta kalmasına yol açan hata düzeltildi.
- Lisans ekranına (Ayarlar → Lokman) ICD-11 için Dünya Sağlık Örgütü atfı eklendi.
- Karşılama ekranında uygulama sürümü görünüyor.

## 0.1.2

> **Önemli:** Bu, kalıcı imza anahtarıyla imzalanan ilk sürüm. Telefonunuzda 0.1.0 ya da 0.1.1 kuruluysa bu sürüm onun üstüne kurulamaz. Önce uygulamada **Paylaş → Paylaş / yedekle** ile yedek alın, eski sürümü kaldırın, 0.1.2'yi kurun ve yedeği içe aktarın. Bundan sonraki sürümler güncelleme olarak kurulur.

- **Yeni logo:** mavi çerçeve içinde ters üçgen, mavi-beyaz tonlarda. Uygulama simgesi, bildirim simgesi ve karşılama ekranı yeni logoyu kullanır.
- **Geçirilmiş hastalıklar:** "Kronik hastalıklar" bölümünün adı "Hastalıklar" oldu. Zatürre, sarılık gibi geçirdiğiniz hastalıkları da başlangıç ve iyileşme tarihiyle ekleyebilirsiniz; liste "Devam eden" ve "Geçirilmiş" olarak ayrılır. Sağlık dosyasında IPS'in geçirilmiş hastalıklar bölümüne, PDF özette ayrı tabloya yazılır.
- Klinikten "iyileşti" olarak gelen hastalıklar artık devam eden hastalık gibi görünmez.
- **Doktor ziyareti ekleme:** Muayeneler bölümüne gittiğiniz doktor ziyaretlerini kendiniz ekleyebilirsiniz: tarih, hastane, doktor/bölüm, neden gittiğiniz, doktorun söylediği tanı ve önerileri, kendi notunuz. Kaydettikten sonra o ziyarette yazılan ilacı ekleyebilirsiniz; ilaç ziyarete bağlanır ve saatinde hatırlatılır. Kontrol tarihi girerseniz randevu ve hatırlatma kendiliğinden oluşur. Bu kayıtlar sağlık dosyasında ve PDF özette "hasta beyanı" olarak yer alır.

## 0.1.1

- Yeni logo: kalbin içinde artı yerine hilal. Uygulama simgesi temalı (tek renkli) simge modunda da doğru görünür; karşılama ekranında da aynı logo kullanılır.

## 0.1.0

Lokman mobil uygulamasının ilk sürümü.

- **Aile profilleri:** kendiniz, çocuğunuz ya da bakımını üstlendiğiniz kişiler için ayrı defter; üst çubuktan tek dokunuşla geçiş.
- **Bugün ekranı:** günün ilaç dozları için büyük “Aldım / Atladım” düğmeleri, yaklaşan aşı ve randevular, son ölçümler.
- **İlaçlar:** 4 adımda ilaç ekleme (ad, doz, saatler, süre), saatinde bildirim, düzenli kullanım oranı.
- **Kayıtlar:** yapılan ve yapılacak aşılar, alerjiler, kronik hastalıklar, ölçümler (tansiyon, nabız, şeker, kilo, boy, ateş, SpO₂; grafikli), randevular, muayeneler.
- **Hatırlatmalar:** ilaç saatleri, aşı gününden önce ve randevudan önce; telefon yeniden başlasa da korunur.
- **Klinikten kayıt alma:** QR kod ya da sağlık dosyası (FHIR R4 / IPS). Aynı dosya iki kez aktarılırsa kayıtlar çoğalmaz.
- **Paylaşma ve yedek:** tüm ya da seçili kayıtlar sağlık dosyası (.json) ve iki dilli (Türkçe/İngilizce) PDF özet olarak paylaşılır.
- Örnek klinik dosyasıyla deneme (Ayarlar).
