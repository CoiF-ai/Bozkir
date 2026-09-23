> En yeni savaş kuralları DUSMANLAR-VE-PORTALLAR.md içindedir: kat başına 10. dalga → boss çağırma → boss yenilgisi → portal. Önceki 20/40/60 seviye geçiş şartı kaldırılmıştır.

# Güncel sürüm: ana menüden oyuna giriş

Önce ana menü açılır. AYARLAR içinden Türkçe/English, müzik ve efekt seviyeleri ayarlanır. OYNA seçili karakterle ilk kata başlar. Güncel değişiklikler için MENU-DIL-MUZIK.md dosyasına bakın. Aşağıdaki eski prototip açıklamaları geçmiş sürümlere aittir.

# Bozkır • Son Alp — Prototip v2

> Güncel açılış artık ana menü çalışmasıdır. PLAY final oynanış adımına kadar hazırlık ekranında kalır. Yeni karakter adları, 100 üzerinden değerler, öğe atlası ve skor kayıtları için **ANA-MENU-NOTLARI.md** dosyasına bakın. Üç kat, 20/40/60 karakter seviyesi, ekonomi, çevre animasyonları ve yeni sesler için **UC-KAT-DUNYA-NOTLARI.md** güncel kaynaktır. Aşağıdaki oynanış bölümleri önceki prototipi anlatır.

Godot 4 ile hazırlanmış, Türk mitolojisinden esinlenen özgün 2D hayatta kalma prototipi. Geçici ad ve kodla çizilen geçici görseller kullanır. Dışarıdan asset gerektirmez.

## Başlatma

Bu bilgisayarda proje klasöründeki **OYNA.cmd** dosyasına çift tıklayın. Başlatıcı bu çalışma alanındaki Godot motorunu kullanır.

Projeyi başka bir klasöre veya bilgisayara taşırsanız: Godot 4 Project Manager içinde **Import / İçe Aktar** ile `project.godot` dosyasını seçin. Editörde **F5** ile oynatın. Bu proje Godot 4.7.2 Windows sürümünde test edildi. Başlatıcı motoru bulamazsa bu yöntem kullanılabilir.

## Kontroller

- WASD veya yön tuşları: hareket.
- Boşluk: hareket yönüne atılma; **3 saniye bekleme**. Dururken baktığın yöne atılırsın. Atılma kısa süre korur ve temas ettiği düşmana hasar verir; arkasında kısa bir iz bırakır.
- Saldırı otomatik; türü seçtiğin karaktere göre değişir.
- Esc / P veya DURAKLAT: duraklat ve devam et.
- Dokunmatik: sol joystick ile hareket, sağ ATIL butonu ile yetenek. İki parmak birlikte desteklenir.
- Pencere odağını kaybettiğinde oyun duraklar. Seviye/sandık seçiminde ve bölüm sonunda süre işlemez.

## Oyun akışı

İlk dokuz dalga 28'er saniyedir. 10. dalgada Tepegöz gelir; yenilene kadar son dalga sürer. Önceki dalgaların yaşayan düşmanları haritada kalır. Boss sırasında düşük sıklıkla zombi desteği gelir.

1. Sürünen zombiler ilk dalgadan itibaren gelir. Yerden çıkışları işaretlidir; düşük can, düşük hasar. Her dalga hız ve hasar kazanırlar.
2. Çürük ağaçlar 3. dalgada katılır. Uzaktan odun fırlatır, yakında dallarıyla alan saldırısı yapar. Normal dekorlar düşman değildir.
3. Kurt adamlar 5. dalgada katılır. Hızlı hareket eder, hazırlıktan sonra atılır. 7. dalgadan itibaren üçlü gruplar gelebilir; grup üyeleri bağımsız saldırı zamanları kullanır. Yüksek deneyim verirler.
4. Tepegöz 10. dalgada belirir. Çok yüksek cana sahiptir. Yakında alan darbesi, uzakta kaya atışı yapar. Saldırı hazırlığı sırasında durur.

**Ağaçların ve kurt adamların saldırı alanları/akın çizgileri gösterilmez.** Ağaçlar hâlâ odun fırlatır ve dallarıyla vurur; mermileri görünür. Zombilerin çıkış işaretleri ve Tepegöz'ün saldırı uyarıları korunur.

Düşen ruh kristalleri deneyim verir; yaklaşıldığında toplanırlar. Seviye atlayınca oyun durur ve üç rastgele geliştirmeden biri seçilir. Can yenileme geliştirmesi de vardır. Boss yenilince bölüm zaferi, can sıfırlanınca yenilgi ekranı açılır.

## Karakter seçimi ve kalıcı açılışlar

Başlangıç ekranındaki **KARAKTER SEÇ** ile seçime geçilir. Bir bölüm, 10. dalgada Tepegöz yenilince tamamlanır; karakterin deneyim seviyesi 10 olması gerekmez.

- **Alp:** başlangıçtan itibaren açık. 100 can, 145 hız, geniş kılıç savuruşu.
- **Kam:** 1. bölüm zaferinde açılır. 85 can, çevresinin tamamına ruh dalgası.
- **Okçu:** 2. bölüm zaferinde açılır. 80 can, 160 hız, uzaktan gerçek ok mermileri.
- **Kargıcı:** 3. bölüm zaferinde açılır. 110 can, uzun ve dar mızrak saldırısı.
- **Demirci:** 4. bölüm zaferinde açılır. 155 can, yavaş ama ağır çekiç saldırısı.

Zafer ekranında **SONRAKİ BÖLÜM • KARAKTER SEÇ** ile eski veya yeni karakter seçilebilir. Sonraki bölümde düşmanların canı ve hasarı artar. Aynı bölümü tekrar tamamlamak ikinci kez karakter açmaz. Bu sürümde beş karakter vardır; hepsi açılınca sonraki bölümler devam eder.

Tamamlanan bölümler ve seçilen karakter Godot'un `user://bozkir_progress.cfg` dosyasına kaydedilir. Oyun kapatılıp açılınca kilitler korunur. Bölüm içindeki deneyim, sandıklar ve geliştirmeler yeni denemede sıfırlanır; yarım kalan oyun kaydı yoktur. Duraklama ekranından karakter değiştirildiğinde mevcut deneme baştan başlar.

## Büyük harita, şifa ve sandıklar

Harita 1800×1120'den **3600×2240** boyutuna büyütüldü; alanı dört katına çıktı. Küçük haritada beyaz nokta oyuncuyu, yeşil artı şifa pınarını, sarı kare açılmamış sandığı gösterir.

- **5 şifa pınarı:** yaklaşınca +35 can verir; 45 saniyede yeniden dolar. Can tamken tüketilmez.
- **9 sandık:** yaklaşınca açılır, +15 can verir ve üç geliştirmeden biri seçilir. Her sandık bir denemede bir kez kullanılabilir.
- **Gece–gündüz:** 180 saniyelik tam çevrim; sabah, gündüz, akşam ve gece arasında yumuşak ışık geçişleri. Ekranda dünya saati görünür. Gece oyuncunun ve şifa pınarlarının çevresi aydınlanır. Şimdilik gündüz/gece düşman değerlerini değiştirmez.
- Hareket hızı Alp için 115'ten 145'e çıkarıldı. Adım, gövde, kol, pelerin ve silah hareketleri güncellendi.

## Dosyalar ve denge

- `scripts/game.gd`: oyun akışı, düşman davranışları, çizimler ve ekranlar. `ENEMY`, `UPGRADES`, `WAVE_SECONDS` başlangıç denge değerleridir.
- `scripts/touch_pad.gd`: çoklu dokunmaya uygun joystick.
- `scripts/roster.gd`: beş karakterin değerleri ve silah türleri.
- `scripts/minimap.gd`: oyuncu, şifa ve sandık haritası.
- `scenes/main.tscn`: açılış sahnesi.
- `tests/campaign_test.gd`: düşmanlar, hasar, deneyim, seviye, dalga, zafer/yenilgi, yeniden başlama ve çift parmak kontrolleri.
- `tests/menu_test.gd`: gece–gündüz, sandık/şifa, karakter açılışları, kayıt, farklı silahlar ve 3 saniyelik atılma.

Test: `godot --headless --path . --script res://tests/campaign_test.gd`

Ek test: `godot --headless --path . --script res://tests/menu_test.gd`

Godot 4.7.2'de 28 temel ve 41 yeni kontrol geçti. Karakter seçimi, gündüz, gece ve sandık ekranları gerçek Godot render çıktılarıyla kontrol edildi. Testler oyuncunun ilerleme kaydını değiştirmez.

## Template / asset nereden bulunur?

Görsel paketleri **top-down pixel art asset pack**, harita parçalarını **tileset**, karakter animasyonlarını **sprite sheet** adlarıyla arayabilirsin.

- [Pixel Frog — Tiny Swords](https://pixelfrog-assets.itch.io/tiny-swords): savaşçı, mızrakçı, okçu, yapılar, arazi ve efektler. İnsan karakterleri ve çevre ücretsiz pakette; ayrı düşman paketi ücretli. 64×64 tile grid kullanır. Savaş animasyonları için başlangıç tercihim bu paket.
- [LimeZu — Serene Village](https://limezu.itch.io/serenevillagerevamped): 16×16 köy, ağaç, arazi ve evler. Stardew Valley benzeri sıcak bir çevre görünümü için uygun bir aday. Sayfa CC BY 4.0 lisansı gösteriyor; üreticiye atıf gerekir. Önizlemedeki karakterler ayrı paketten.
- [Kenney — Tiny Dungeon](https://kenney.nl/assets/tiny-dungeon) ve [Tiny Town](https://kenney.nl/assets/tiny-town): ücretsiz 16×16, CC0 paketler. Basit ve tutarlı bir görsel temel için.
- [Cup Nooble — Sprout Lands](https://cupnooble.itch.io/sprout-lands-asset-pack): pastel çiftlik/doğa görünümü. Ücretsiz sürüm ticari olmayan projeler için; üretici ticari kullanım için premium sürümü belirtiyor.

Bu paketlerden henüz dosya indirilmedi veya oyuna eklenmedi. Tepegöz, çürük ağaç ve Türk mitolojisi kıyafetleri için seçilen temel stile uyumlu özel çizimler gerekebilir. Kaynak projesiyle yeniden dağıtım koşulları her paketin kendi lisansına bağlıdır. Kaynak sayfaları 19 Eylül 2026'da kontrol edildi.

## Prototip sınırları

Bu teslim Godot kaynak projesidir; APK veya mağazaya hazır mobil uygulama değildir. Yatay yön ve dokunmatik kontroller hazırlanmıştır; gerçek Android/iOS cihazında henüz test edilmedi. Android dışa aktarımı için Godot export şablonları ve Android geliştirme araçları gerekir.

Ses/müzik, gerçek animasyon assetleri ve mağaza entegrasyonları eklenmedi. Düşman ve oyuncu görselleri kodla çizilen yer tutuculardır. Haritadaki dekorların çarpışması yoktur. Denge değerleri oynanış denemeleriyle ayarlanmalıdır.

`ONIZLEME.png`, `GECE.png` ve `KARAKTERLER.png` yeni arayüzü gösteren hazırlanmış test sahneleridir; oyuncunun gerçek ilerlemesini göstermezler. Gerçek oyunda karakterler bölüm zaferleriyle açılır, boss 10. dalgada gelir.

