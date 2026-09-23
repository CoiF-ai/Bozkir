# Menü, dil ve müzik — güncel akış

Bu not önceki belgelerdeki “PLAY henüz oyunu açmaz” açıklamasının yerini alır.

Oyun her açılışta ana menüye gelir. Oyuncu ayarlara bakabilir, açık karakterlerden birini seçebilir ve OYNA / PLAY ile ilk kata doğrudan başlayabilir. Menü müziği geçişte durur, kat müziği başlar. Duraklatma ekranındaki ANA MENÜ / MAIN MENU menüye döner. Ölümde menüye dönüş ve yeniden başlama için kafatası çatlama geçişi korunur.

## İki dil

İlk açılış dili Türkçedir. AYARLAR içindeki Dil / Language seçimi Türkçe ve English sunar. Seçim hemen uygulanır; müzik ve efekt seviyeleri değişmeden korunur. Dil ve ses ayarları cihazdaki `user://bozkir_settings.cfg` dosyasına kaydedilir. Dil seçimi oyun içi HUD, geliştirmeler, sandıklar, karakter açıklamaları, dünya/animasyon önizlemeleri, yardım, skorlar ve ölüm ekranına uygulanır. Karakter adları özel isim olarak korunur.

Çeviri kaynağı `localization/en.json`, dil yöneticisi `scripts/localization.gd` dosyasıdır. Desteklenmeyen dil kayıtları Türkçeye döner.

## Menü çalma listesi

1. Lunarecst — War Drums (projede War Drums.mp3)
2. Re_EchoMainMenu (projede Re Echo.mp3)
3. Agony
4. Hail
5. Lily
6. Loose Me
7. Subnautica
8. Wind

Yeni iki dosya kullanıcının masaüstündeki müzikler klasöründen kopyalandı; kaynaklar değiştirilmedi. Menü War Drums ile açılır. Parça bitince sonraki başlar; sekizinci parçadan sonra başa döner. Menüdeki > düğmesi parçayı atlar. Müzik ve efekt sesleri ayrı ayarlanır. Yeni menü parçaları savaş müziğini değiştirmez.

## Doğrulama

37 menü, 80 kampanya, 621 karakter ve 44 dil/geçiş kontrolü geçti (toplam 782). Yeni parçalar Godot'a MP3 olarak içe aktarıldı. Türkçe ve İngilizce PNG'ler gerçek menü render çıktılarıdır. Menüden oyuna geçiş başsız test edildi; görünür oynanış oturumu açılmadı. Mobil cihaz denemesi, nihai denge ve özel ulti sistemleri hâlâ sonraki aşamalardır.
