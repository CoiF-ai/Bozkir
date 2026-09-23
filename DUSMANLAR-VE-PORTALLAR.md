# Yeni düşmanlar, bosslar ve portal akışı

Bu belge önceki 20/40/60 karakter seviyesinde kat bitirme ve Tepegöz kurallarının yerini alır. Kullanıcı onayı: her katın 10. dalgasında çağırma alanı açılır; boss yenilir, uzaktaki portala gidilip etkileşilerek kat tamamlanır. Karakter seviyesi geçiş şartı değildir.

## Dalgalar ve güçlenme

Dalgalar 28 saniyedir; seçim ve duraklatma ekranlarında zaman işlemez. İlk iki katta zombi ilk dalgadan, karanlık yaratık üçüncü dalgadan, beyaz kurt beşinci dalgadan, kırmızı kurt yedinci dalgadan gelir. Dokuzuncu dalgadan itibaren alfa merkezli sürüler rastgele eklenir. Eski düşmanlar tamamen silinmez; sonraki aşamalarda da daha az sıklıkla karışırlar. Kurtların temel güç katsayıları beyaz %50, kırmızı %70, siyah alfa %100'dür; alfa ayrıca 2,4 kat cana sahiptir.

Katların NPC başlangıç gücü %50 / %75 / %100'dür. Karakter seviyesi ve dalga arttıkça can, hasar, hareket hızı ve saldırı sıklığı artar. Mevcut yaşayan NPC'ler de güncellenir; kalan can yüzdeleri korunur. NPC hareket/saldırı büyümesi temel kat değerinin iki katında sınırlandırılır; can ve hasar artmaya devam eder. Demonlar ve ruhlar da bu kurala dahildir.

## Bosslar

Birinci ve ikinci katta Yelbeğen, üçüncü katta Sorcerer paketindeki Son Büyücü vardır. İkinci kat için ayrıca boss asseti belirtilmediğinden Yelbeğen'in daha güçlü sürümü kullanılır.

- Boss 1: saldırı %80, saldırı hızı %95, hareket %100; 6.000 can.
- Boss 2: saldırı %95, saldırı hızı %100, hareket %120; 14.000 can.
- Boss 3: saldırı %120, saldırı hızı %100, hareket %90; 28.000 can.

Yüzdeler boss temel değerlerine uygulanır: 50 ham hasar, saniyede 1 saldırı hazırlık tabanı ve 120 hareket birimi. Gerçek vuruş aralığı hazırlık ve mesafeye de bağlıdır. Boss canları ilk denge taslağıdır. Yakın alan darbesi ve çevik atılma saldırıları vardır.

10. dalgada rastgele ve uzakta bir sunak belirir. Mor halka küçük haritada görünür. Yanına gelip E veya BOSS ÇAĞIR düğmesiyle çağırılır; uzaktan ve ikinci kez çağrı yapılamaz.

İlk iki katta dört dakika boss çağrıldığı anda başlar. Boss bu sürede ölmezse demon/kan ruhu akınları başlar. Sayaç seçim/duraklama ekranlarında durur. Boss yenilse bile başlamış akın portala kadar devam eder.

Boss öldüğünde oyuncudan en az 650 birim uzakta ana portal açılır. Kat anında değişmez. Oyuncu savaşabilir, EXP/altın toplayabilir, seviye atlayabilir. Yeşil portalın yanına gelip E veya PORTALA GİR ile geçilir. Yerel süre kaydı ve karakter açılışı portal geçişinde yapılır. Son kattaki portal kampanyayı kazanılmış olarak tamamlar.

## Madness katı

Zombi yerini Dark VFX ile gösterilen hızlı, orta hasarlı karanlık ruhlar alır; çıkış animasyonları yerden belirmeyi gösterir. Ortam ayrıca koyulaştırılır. Normal Evil Wizard mini bossları altıncı dalgadan ve karakter seviyesi 30'dan itibaren rastgele gelir; ağır alan/menzilli saldırı yapar ve üçlü ruh sürüleri çağırır. Bu eşikler ilk denge taslağıdır.

Son boss çağrısı dört dakika beklemeden akını açar; bir Evil Wizard da başlangıçta gelir. Çağrıdan itibaren demon, ruh ve büyücüler hareket ×2, hasar ×1,5 ve saldırı sıklığı ×1,4 ek çarpan alır. Bu durum portal geçişine kadar sürer. Sahnedeki düşman sayısı performans için 120 ile sınırlandırılmıştır; yer açıldıkça akın devam eder.

## Assetlerin kapsamı

Zombie paketi yürüyüş/saldırı/ölüm; kurt paketinin üç rengi; Tiny RPG'nin Demon ve Blood Monster animasyonları; Yelbeğen'in dört yönü; Evil Wizard ve Sorcerer saldırıları bağlandı. Monster paketi tek yaratık içerdiğinden renk tonlarıyla üç varyant yapılır. Tiny RPG paketinde ayrı ghost bulunmadığı için Blood Monster ruh rolünü oynar. Dark VFX bir efekt paketidir; ruh düşmanı görünümü ve çıkış animasyonu olarak kullanılır.

Kaynaklarda bulunmayan özel ölüm hareketleri (Yelbeğen/Sorcerer gibi) için mevcut görüntü soldurulur. Sorcerer'ın düz arka planı ve idle görselindeki palet şeridi çalışma anında şeffaflaştırılır; kaynak PNG'ler değiştirilmez. Yalnızca tek yönden çizilmiş paketler yatay çevrilir; yeni yön çizimleri üretilmemiştir.

## Önizleme ve test

Menüde DÜŞMANLAR animasyonlu atlası açar. DUSMANLAR-SON-ONIZLEME.png ve DUSMAN-ANIMASYONLARI.gif gerçek Godot atlas renderlarıdır. MADNESS-SAHNE-ONIZLEME.png hazırlanmış, simülasyonu durdurulmuş son kat sahnesidir; gerçek bir oyuncunun tamamladığı koşuyu göstermez.

339 yeni düşman/portal kontrolü ve önceki 800 kontrol geçti (toplam 1.139). Kontroller kare sınırlarını, güçlenmeyi, boss yüzdelerini, 240 saniye eşiğini, çağırma sınırlarını, portal mesafesini ve üç katın bitişini kapsar. Tam koşu dengesi ve gerçek mobil cihaz performansı henüz test edilmedi.
