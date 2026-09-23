# v0.2 — hareket, takip, harita ve gece akını

- Karakter hareket hızı yaklaşık %45; otomatik saldırı temposu yaklaşık %30 arttı. Atılma hızı 510 → 650; bekleme 3 saniye.
- Dalga süresi 28 → 22 saniye. Boss hâlâ 10. dalgada çağrılır; 240 saniyelik boss süresi korunur.
- Kare başına 50 ms kesintisi yerine 60 Hz sabit simülasyon adımları kullanılır. 10/15/30/60 FPS senaryolarında bir saniyelik yürüme mesafesi ve oyun zamanı eşittir. Uzun uygulama donmaları için tek karede 250 ms üst sınırı vardır.
- Uzaktan saldıran karanlık yaratıklar 215 pikselde durmaz; yürüyerek takip eder ve saldırı hazırlığı sırasında da yaklaşır. Diğer karanlık türlerin yeni hedefe yönelmesi test edildi.
- Normal düşmanların hareket hızının düşük katlarda aşırı azalması düzeltildi; can/hasar kat katsayıları korunur.
- Görüş yarıçapı gündüz 440, gece 230 oyun pikseli; kenarda 90 piksellik yumuşak kararma. Arayüz kararmadan etkilenmez.
- 21:00–06:00 arasında hareket ×1.25, saldırı hızı ×1.35, hasar ×1.15. Normal akınlar ve boss destek akınları %40 daha kısa aralıklarla gelir. Normal gruba bir ek temel düşman katılır. Mevcut düşmanlar da değişir; çarpanlar birikmez ve şafakta kalkar.
- Mobilde yalnızca oyuncunun dinamik ışığı açık. Arayüz verileri 10 Hz güncellenir; ekran dışı aktörlerin çizimi atlanır.
- Referansın orman/şelale, kristalli mağara ve kızıl harabe temaları yeni bir zemin atlasıyla oyuna bağlandı. Bu, yandan görülen referansın serbest dolaşıma uygun üstten görünüm uyarlamasıdır; platform oyunu veya referansın birebir geometrisi değildir. Sandık, şifa, düşman ve portal ayrı etkileşimli nesnelerdir. Yaprak/kristal/köz parçacıkları hareketlidir; atlasın mimari çizimleri dekoratiftir.

## Doğrulama

Toplam 1221 otomatik kontrol geçti: önceki 1139 + dokunmatik 39 + hız/takip 31 + gece 12. Masaüstü gerçek çizim akışındaki 6 kontrol de geçti. RTX 4050 üzerinde yaklaşık 40 düşmanla medyan 16.67 ms, p95 17.06 ms ölçüldü. Bunlar Android FPS sonucu değildir. ADB bu oturumda kullanıcı klasörünü açamadığı için telefonda yeni sürümün kurulumu ve performansı doğrulanmadı.

## Görsel üretim

`assets/world/three-realms.png`, yerleşik image_gen aracıyla kullanıcının üç katlı harita referansından üretildi. İstem: aynı piksel sanatı dokusu ve renkleriyle üç eşit yatay bölümden oluşan tek bir üstten görünüm arena atlası; üstte orman/şelale, ortada kristalli mağara, altta lavlı harabe; merkezde açık yürünebilir zemin, çevrede mimari ve bitkiler; karakter, sandık, arayüz ve yazı olmaması. Üretilen atlas projeye kopyalandı ve üç katın gerçek zemin çizimine bağlandı.
