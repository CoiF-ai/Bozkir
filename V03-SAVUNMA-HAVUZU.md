# v0.3 — 500 savunma öğesi

Havuzda 500 yeni savunma öğesi var: 10 çalışan mekanizma × 5 karakter × 10 özellik profili. Bunlar 500 ayrı temel mekanik veya 500 farklı çizim değildir. Her profilin gücü, menzili ve tetikleme aralığı farklıdır. Her karakterin 100 savunma öğesi, eski dört karakter öğesi ve iki ortak şans öğesi bulunur; toplam katalog 522 öğedir.

Mekanizmalar: yenilenen kalkan, döner tornado, otomatik alev konisi, yavaşlatan buz halkası, darbe alınca yansıtan diken zırhı, üç döner bıçak, yük tüketen mermi siperi, can yenileyen totem, üç hedefe zincir yıldırım, geri savuran itme dalgası.

Alp kalkan/diken/siperde %20 güçlüdür. Kam tornado/buz/yıldırımda %20 güçlüdür. Kıyat'ın alanları %15 geniştir. Yelme'nin aralıkları %15 kısadır. Çura %15 güçlü, %10 daha uzun aralıklıdır. Bakır/Çevik/Geniş regular; Demir/Yoğun/Sürekli epic; Gümüş/Uzak/Ezici legend; Göksel destansıdır.

Sandık önce mevcut şansla nadirlik seçer. Regular ve Epic ödüllerde %25 ortak şans öğesi kontrolü yapılır. Kalan ödüllerde %80 savunma, %20 eski karakter öğesi seçilir. Legend ve Destansı için doğrudan %80 savunma / %20 karakter öğesi dağılımı kullanılır. Sandık ücreti, satın alma onayı, tek ödül ve bırakınca geri ödeme olmaması korunur.

AL VE KUŞAN savunmayı otomatik etkinleştirir. Aynı türün en yüksek sıralı profili çalışır; ek buluntular en fazla üç yığına çıkar, ilkinden sonraki her yığın %15 güç ekler (en fazla %30). Zayıf profil daha güçlü olanı değiştirmez. Maksimum 10 etkin savunma grubu sayesinde 500 ayrı düğüm/efekt yaratılmaz. Çanta etkin profili ve yığın sayısını gösterir. Katlar arasında savunmalar kalır; yeni koşuda sıfırlanır. Menüdeki SANDIK İTEMLERİ bölümünde seçilen karakterin bütün havuzu kaydırılabilir.

Yeni savunma testinde 1022 kontrol geçti: katalog sayısı/benzersizliği, karakter filtresi, sandıkta erişilebilir mekanizmalar, kuşanma, kalkan, mermi engelleme, şifa, hasar, buz, savurma, yığın sınırı ve koşu sıfırlama. Sekiz ilgili test takımında toplam 1542 kontrol geçti. Masaüstü gerçek çizimde 10 etkin mekanizma ve 40 düşmanla medyan 16.66 ms, p95 17.07 ms ölçüldü. Bu Android FPS ölçümü değildir; yeni APK'nın telefondaki performansı henüz doğrulanmadı.

Savunmaların 10 mekanizmasına ayrı kod tabanlı SVG simgeleri eklendi; eski öğeler Raven simgelerini kullanmaya devam eder. Türkçe ve İngilizce adlar/açıklamalar eklendi.
