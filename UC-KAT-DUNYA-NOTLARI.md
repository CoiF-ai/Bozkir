# Üç katlı dünya güncellemesi

Godot kaynak projesine uygulanmıştır. PLAY final oynanış adımına kadar hazırlık penceresinde kalır. PNG ve GIF, Godot menüsünden alınan gerçek görüntülerdir. Görseller referanstan esinlenen kodla çizilmiş yer tutuculardır; nihai çevre assetleri değildir.

## İlerleme ve düşmanlar

- Gök Ormanı: karakter seviyesi 20'de tamamlanır; maksimum düşman değerlerinin %30'u (ilk denge önerisi).
- Kristal Derinlik: karakter seviyesi 40'ta tamamlanır; maksimum değerlerin %60'ı.
- Kızıl Hisar: karakter seviyesi 60'ta tamamlanır; maksimum değerlerin %100'ü sabit kalır.
- Her katın alanı 4200 × 2600 oyun birimidir. Kat değiştirirken seviye, EXP, altın ve geliştirmeler korunur.
- Oranlar can, hasar, hareket hızı ve saldırı sıklığına uygulanır. Zombi, çürük ağaç, kurt adam ve mevcut tek boss Tepegöz için tanımlıdır.
- Geçiş koşulu karakter seviyesidir; boss öldürmek ayrıca zorunlu değildir. İlk iki katta boss hedef seviyeden iki seviye önce, üçüncü katta başlangıçta gelir.
- Her katın etkin tamamlanma süresi yerel skor tablosuna yazılır. Duraklama süresi sayılmaz. Katlar arasında açık karakterlerden seçim yapılabilir. Karakter açma sayacı toplam kat zaferlerini sayar; tekrar kazanılan katlar da sayılır.

## Ekonomi

- Düşmanlar hem EXP hem altın bırakır. Kat geçişinde yerde kalan ödüller toplanır.
- Sandık fiyatları 20 → 40 → 80 → 160 şeklinde ikiye katlanır; kat geçişinde sıfırlanmaz. Yeni koşuda sıfırlanır. Teknik taşma koruması 40 katlamada devreye girer.
- Satın almadan önce fiyat gösterilir; yetersiz bakiyeden para kesilmez. Sandık şu aşamada mevcut geliştirme seçimini açar; item envanteri sonraki adımdır.
- İlk denge önerisi: altın çarpanı katlarda 1× / 2× / 4×; her sandık temel çarpana %15 ekler. Örneğin iki sandık sonrası ilk katta 1,30× olur. Sandık maliyeti altın gelirinden daha hızlı büyür; final oyun denemesinde ayarlanmalıdır.
- Şifa alanları toplam 15 / 40 / 80 / 130 / 200 öldürmede açılır. Kullanılan alan 25 yeni öldürme ardından tekrar dolar. Can tamken tüketilmez. Bunlar ilk denge önerileridir.

## Animasyon ve ses

Ormanda bulutlar, yapraklar ve şelaleler; mağarada kristal parıltısı, su ve parçacıklar; hisarda bayraklar, lav ve küller hareket eder. Menüde DÜNYA düğmesi hareketli üç kat önizlemesini açar. Bu yandan görünüm bir dünya tanıtımıdır; savaş sahnesi üstten görünümdedir.

Music.zip içindeki Agony, Hail, Lily, Loose Me, Subnautica ve Wind menüde sırayla çalar, son parçadan sonra başa döner. Menüde sonraki parça düğmesi ve ses ayarları vardır. İki Craftpix paketinden ayak sesi, silah, darbe, atılma, sandık ve arayüz efektleri bağlandı. Katlara ayrı savaş müzikleri atandı. Lazer/radyo gibi kullanılmayan sesler kaynak kütüphanede tutulur. Paket lisans metinleri audio altındaki source klasörlerinde korunur.

## Doğrulama ve sonraki adım

`godot --headless --audio-driver Dummy --path . --script res://tests/menu_test.gd` — 37 kontrol.

`godot --headless --audio-driver Dummy --path . --script res://tests/campaign_test.gd` — 78 kontrol.

Toplam 115 kontrol geçti. Görünür oynanış oturumu başlatılmadı; kampanya kuralları başsız test edildi. Gerçek mobil cihaz performansı ve tam koşu dengesi henüz doğrulanmadı. Karakter itemleri, nihai karakter animasyonları, ulti davranışları ve 100 üzerinden karakter değerlerinin gerçek savaş birimlerine dönüşümü sonraki adımlardır.
