# Karakter assetleri ve ölüm ekranı

Kullanıcının paketleri kopyalanarak projeye eklendi; kaynak ZIP ve PNG dosyaları değiştirilmedi. Kareler Godot AtlasTexture bölgeleriyle okunur, şeffaflık korunur. Hareket her yöne serbesttir; paketler yandan görünüşlü olduğundan sağ/sol yön için yatay çevirme kullanılır. Ayrı yukarı/aşağı sprite çizimleri yoktur.

- Alp: FreeKnight_v1, Colour1/Outline. Bekleme, koşu, saldırı, yuvarlanarak atılma, hasar ve ölüm.
- Kam: Necromancer_creativekind-Sheet, 160×128 kareler. Bekleme, hareket, büyü saldırısı, hasar, ölüm ve ek büyü satırı. Otomatik saldırısı karanlık menzilli mermiye dönüştürüldü.
- Kıyat: ArcherHero. Bekleme, koşu, yay saldırısı, atılma ve ölüm. Sprite sayfasındaki açıklama yazıları karelere dahil edilmez. Ayrı hasar animasyonu olmadığı için bekleme karesi kullanılır.
- Yelme: 2D_SL_Knight, 128×64 kareler. Bekleme, koşu, saldırı, yuvarlanma, hasar ve ölüm. Paketteki kılıç görünümü korunmuştur; savaş hesabı mızrak menziliyle çalışır. Özel mızrak sprite çizimi henüz yoktur.
- Çura: Knight klasörünün noBKG şeritleri. Animasyona göre farklı kare genişlikleri kullanılır. Paketin kılıç/kalkan görünümü korunmuştur; ağır silah savaş hesabı devam eder. Özel ağır çekiç çizimi henüz yoktur.

Menüde ANİMASYON düğmesi bekleme/koşu/saldırı/ölüm döngülerini gösterir. Atılma ve hasar hareketleri savaş olaylarına bağlıdır. Paketlerdeki platform hareketlerinin tümü (tırmanma, zıplama vb.) üstten görünüşlü oyuna bağlanmamıştır. Ultinin enerji sistemi ve önceki özel ulti davranışları bu teslimde tamamlanmış değildir.

## Petler

Alp 20. seviyeyi geçince (21+) Hobbit alır. Kullanıcının onayıyla Yelme ve Çura da kendi petleri belirlenene kadar aynı eşiğe sahip geçici Hobbit kullanır. Hobbit oyuncuyu takip eden yol arkadaşıdır; bu aşamada hasar vermez. Kıyat petsizdir.

Kam 30. seviyede Bot Wheel alır. Ultiye bağlı çağırma yerine seviye şartı seçildi. Pet aktifken 10 saniyede bir 3 saniyelik karanlık kalkan açılır: düşman mermileri yok edilir, yakın dövüş darbeleri engellenmez. 10/3 saniye ilk denge önerisidir. Önceden konuşulan 10. seviye absorpsiyonla ulti doldurma sistemi bu kalkanla aynı sistem değildir; henüz bağlanmamıştır.

## Ölüm

YOU DIED ekranında özgün kodla çizilmiş piksel kafatası ve özgün beş saniyelik karanlık synth sesi vardır. Filigranlı örnek JPG doğrudan oyun asseti olarak kullanılmamıştır. Yeniden başla veya ana menü düğmesinde 0,75 saniyelik çatlama/parçaların ayrılması geçişi tamamlanır, ardından işlem yapılır. Çift tıklama ikinci işlem başlatmaz. Yeniden başlama mevcut karakterle yeni koşu açar; menüye dönüş gerçek ana menü sahnesini yükler.

Menü içindeki ölüm önizlemesinde iki düğme de çatlamadan sonra önizlemeyi kapatır; oyun açılmaz. PLAY final oynanış aşamasına kadar hazırlık ekranında kalır.

## Doğrulama

621 karakter kontrolü (sprite bölgeleri, dosyalar, pet eşikleri, kalkan, ölüm ve yeniden başlama), 37 menü ve 78 kampanya kontrolü geçti. Gerçek mobil cihaz ve tam koşu denge testi yapılmadı. PNG/GIF dosyaları Godot menüsünün gerçek render çıktılarıdır.

Test: `godot --headless --audio-driver Dummy --path . --script res://tests/character_test.gd`
