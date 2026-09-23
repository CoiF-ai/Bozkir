# Bayrak, kedi ve karaktere özel sandıklar

Menüde BAYRAK düğmesi Kenney paketindeki ülke bayraklarını kodları ve görselleriyle listeler. Seçim ses/dil ayarlarıyla birlikte saklanır ve yeni koşuya aktarılır.

## İşaretler

- F tuşu veya mobil BAYRAK + KEDİ düğmesi oyuncunun o anki konumuna bir bayrak ve dekoratif kedi bırakır.
- Koşu başına iki hak vardır. Kat değiştirmek hakları yenilemez; yeni koşu yeniler. İşaretler bırakıldıkları katta kalır.
- Kedi bekleme animasyonu oynatır; saldırı, toplama, takip, engelleme veya istatistik etkisi yoktur. Savaş petlerinden ayrıdır.
- Ölüm, katı ve tam konumu `user://bozkir_markers.cfg` dosyasına kaydeder. Sonraki koşuda o kata gelindiğinde son ölüm noktasında bayrak ve kedi görünür. Yeni ölüm eski ölüm kaydının yerini alır. Bu otomatik işaret iki hakkı tüketmez.
- Küçük haritada elle bırakılan işaretler mavi nokta, son ölüm pembe çarpı olarak gösterilir.

## Sandık ödülleri

Raven paketindeki ikonlar kullanıldı. İlk havuzda her karakter için dört item ve ortak iki şans itemi bulunur: toplam 22 item tanımı. Paketteki bütün ikonlar ayrı item olarak tanımlanmış değildir.

Havuz, koşuya başlarken seçilen karaktere sabitlenir. Kat aralarında karakter değişse de sandıklar ilk karaktere uygun itemler veya ortak şans itemleri verir. Item bonusları mevcut karaktere uygulanır ve kat geçişlerinde korunur. Yeni koşuda itemler/şans sıfırlanır.

Sandık satın alınır; rastgele tek ödül gösterilir. AL VE KUŞAN etkileri uygular, BIRAK ödülü reddeder. Reddedilen sandık ücreti iade edilmez ve yeniden çekiliş yapılmaz. Aynı ödül iki kez alınamaz. Farklı sandıklardan aynı item yeniden gelebilir ve bonusları birikir.

- Alp: hasar ve azami can.
- Kam: hasar ve büyü menzili.
- Kıyat: öncelikle saldırı hızı.
- Yelme: menzil ve saldırı hızı.
- Çura: yüksek hasar karşılığında bazı nadirliklerde hareket kaybı.
- Şans Boncuğu +4; Kutlu Tılsım +9 şans verir. Toplam şans en fazla 60'tır.

Başlangıç nadirlik oranları Regular %70, Epic %22, Legend %7, Destansı %1. Şans 60 iken oranlar %28 / %43 / %22 / %7 olur. Her zaman toplam %100'dür. Regular/Epic sonucu çıktığında %25 olasılıkla o nadirliğin ortak şans itemi seçilir; kalanında karakter itemi seçilir. Bunlar ilk denge değerleridir.

I tuşu veya ÇANTA düğmesi alınan itemleri, mevcut şansı ve gerçek nadirlik oranlarını gösterir. Menüde ÖĞELER seçili karakterin havuzunu ve bonuslarını önizler. Seviye atlama geliştirmeleri ayrı sistem olarak korunur; sandıklar artık eski geliştirme seçimini açmaz. Eski item_catalog.gd taslağı aktif sandık havuzu değildir.

## Kontroller

18 yeni marker/loot kontrolü geçti: iki hak sınırı, katlar arasında korunma, kayıt okuma, başlangıç karakterine bağlı havuz, 22 itemin erişilebilirliği, olasılık toplamları, bonus uygulama ve çift ödül engeli. Önceki menü, karakter, dil/geçiş ve kampanya kontrolleriyle birlikte toplam 800 kontrol geçti. Tam koşu dengesi ve gerçek mobil cihaz denemesi henüz yapılmadı.
