# Bozkır 0.4-test

- Orman, mağara ve harabe katları için üç ayrı 1448×1086 zemin dokusu. Dokular dev harita boyutuna esnetilmeden kendi ölçeğinde tekrarlanır. Çevrenin parçacık animasyonları korunur.
- Döner bıçakların yakın mesafedeki kör alanı kaldırıldı. Etkin menzildeki düşmanlara periyodik hasar verir; isabetler görsel olarak belirtilir.
- Savunma kalkanı alındığında dolar, gelen hasarı kapasitesi kadar emer ve kendi bekleme süresinde yenilenir. Eski Oba Kalkanı da gerçek kalkan sağlar. Kalan kapasite ve yenilenme süresi ekranda görünür.
- Düşman altını üç katına çıktı. İlk zombi 6 altın verir. Sandık fiyatları 20 → 40 → 80 şeklinde devam eder.
- Alp fırlama, Kam yönlendirilebilir uçuş, Kıyat hedefe kanca, Yelme inişte alan hasarı, Çura döner kılıç kullanır. Hareket yeteneklerinin bekleme süresi 3 saniyedir.
- Hareket ve saldırı yönleri tüm açılarda çalışır. Mevcut yan görünüşlü karakter çizimleri korunur; gerçek ön/arka animasyonlar için ek sprite çizimleri gerekir.
- Menü ve oyun arayüzü ekran oranına ve mobil güvenli alana uyarlanır. Beş ekran oranı ve sentetik çentik alanları otomatik test edilir. Her telefon modelinde fiziksel test yapılmış değildir.

## Görsel kaynaklar

Yeni forest-hd.png, cavern-hd.png ve ruins-hd.png dokuları OpenAI imagegen ile üretildi. Ortak üretim tarifi: tepeden ortografik, kenarları tekrar edebilir, ayrıntılı küçük piksel kümeleriyle ortaçağ Türk mitolojisi hayatta kalma oyunu zemini; karakter, arayüz, yazı, büyük engel veya perspektif ufku yok. Orman için yosun, çim ve toprak; mağara için mavi-gri taş ve küçük kristal izleri; harabe için sıcak koyu taş döşeme ve hafif kor izleri kullanıldı.

## Doğrulama ve teslim

Godot otomatik testleri ve masaüstü oyun içi görsel kontroller uygulanır. APK geliştirme imzasıyla hazırlanır. Gerçek Android cihazındaki performans ve dokunmatik denemesi ayrıca gereklidir. Kurulum için ZIP dışındaki ANDROID-KURULUM.md dosyasını okuyun. Google Play yayını ve GitHub düzenlemesi bu paketin sonraki aşamasıdır.
