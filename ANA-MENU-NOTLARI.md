# Ana menü — karakterler, öğeler ve skorlar

Projenin açılış sahnesi `scenes/menu.tscn`. PLAY şu aşamada yalnızca hazırlık penceresi açar. Kullanıcının istediği üzere oynanışa geçiş final adımına bırakılmıştır. Eski oyun sahnesi korunmuştur.

## Karakter tasarımları

Menüdeki hasar / hız / saldırı hızı değerleri 100 üzerindendir:

- Alp: 65 / 45 / 30. Yakın dövüş; geliştirme aldığında kalkan. Ulti: gökten yıldırım.
- Kam: 55 / 65 / 45. Uzaktan büyü; 10. seviyede atılan mermileri emip ulti enerjisi toplama. Ultinin saldırı biçimi henüz kullanıcı tarafından belirlenmedi.
- Kıyat (eski Okçu): 50 / 60 / 70. Uzaktan ok; dolan ultide yerden çıkan oklar. 11. seviyeden itibaren rastgele efsanevi yetenekler.
- Yelme (eski Kargıcı): 50 / 40 / 45. Uzun mızrak; ultide seri mızrak vuruşları.
- Çura (eski Demirci): 75 / 30 / 40. Ağır savaşçı; ultide seri ağır darbeler.

Bu bilgiler `scripts/roster.gd` içinde `ratings`, `style`, `passive`, `ultimate` alanlarındadır. Menü karakter kartları ve DETAYLAR düğmesiyle hepsi incelenebilir. Kilitli karakteri incelemek onu açmaz.

Savaş kodundaki eski piksel/saniye, ham hasar ve saldırı aralığı değerleri ayrı tutuldu. 100 üzerinden tasarım değerlerinin gerçek savaş birimlerine dönüşümü, ultinin dolması/çalışması, Kam'ın menzilli büyüsü ve efsanevi yetenek seçimi final oynanış aşamasında bağlanacak. Bu menü güncellemesi bunların savaş içinde çalıştığı anlamına gelmez.

## Öğe atlası

Regular → Epic → Legend → Destansı sırası kullanıldı. Her sınıfta iki örnek olmak üzere sekiz öğe vardır. Bazıları yalnızca fayda verir, bazıları özellikler arasında takas yapar; Çatlak Mühür yalnızca dezavantajlı bir örnektir. İsimler ve sayılar ilk denge taslağıdır.

`scripts/item_catalog.gd` veri kataloğunu ve 0–100 sınırında avantaj/dezavantaj hesabını içerir. Gerçek dünyada düşme/toplama, envanter ve kuşanma henüz bağlanmadı. Bu örnekler bütün karakterler içindir; öğeyle yeni karakter açılması henüz tanımlanmadı.

## Skor tablosu

`scripts/scoreboard.gd` her karakter/bölüm için en iyi tamamlanma süresini saniye cinsinden yerel `user://bozkir_scores.cfg` dosyasında saklar. Kazanılan oyun için kayıt bağlantısı eski oyun sahnesinin bitişine eklendi. Yenilgiler kayıt oluşturmaz. Oyun içi etkin süre kullanılır; duraklama ve geliştirme seçimi süreye eklenmez.

Bu bir çevrim içi oyuncu sıralaması değildir. Sunucu ve oyuncu hesabı yoktur. Mevcut kaydı olmayan kullanıcıya örnek/sahte skor gösterilmez. Eski sürümlerin süreleri kaydedilmediğinden geçmiş zaferlerden süre üretilemez.

## Ses ve menü

Music.zip içindeki altı parça menüde sırayla çalar; son parçadan sonra liste başa döner. Güncel dünya ve ekonomi kuralları UC-KAT-DUNYA-NOTLARI.md içindedir. SETTINGS müzik/efekt sesini ayarlar; SES düğmesi müziği susturur. Butonlarda basılma hareketi ve kısa ses vardır. Menü ayarları ayrı `user://bozkir_settings.cfg` dosyasında saklanır.

## Doğrulama

`godot --headless --audio-driver Dummy --path . --script res://tests/menu_test.gd`

37 kontrol: adlar/değerler, seviye eşikleri, öğe etkileri ve sınırları, skor doğrulaması/sıralama/kayıt, menü kartları, ses ve PLAY'in menüde kalması. Test sırasında oynanış sahnesi yüklenmez. PNG'ler gerçek Godot menü render çıktılarıdır.

