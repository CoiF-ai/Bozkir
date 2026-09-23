extends RefCounted
## Original fantasy interpretations, not historical character descriptions.
const HEROES := [
	{"name": "Alp", "description": "Yakın savaşçı\nKılıç ve kalkan", "hp": 100.0, "speed": 210.0, "damage": 23.0, "reach": 79.0, "period": 0.50, "weapon": "sword", "color": Color("368c8b"),
		"ratings": {"damage": 65, "speed": 45, "attack_speed": 30}, "style": "Yakın dövüş", "passive": "Geliştirme aldığında kendine koruyucu bir kalkan oluşturur.", "passive_level": 1,
		"ultimate": "Gök Yıldırımı", "ultimate_text": "Gökten düşen yıldırımla düşmanlarını vurur.", "ultimate_gate": "Ulti enerjisi dolduğunda", "legendary_level": 0},
	{"name": "Kam", "description": "Uzaktan büyü\nMermi emme", "hp": 85.0, "speed": 210.0, "damage": 21.0, "reach": 110.0, "period": 0.69, "weapon": "pulse", "color": Color("a989d2"),
		"ratings": {"damage": 55, "speed": 65, "attack_speed": 45}, "style": "Uzaktan büyü", "passive": "10. seviyede emme yeteneği açılır. Üzerine atılan mermileri emerek ulti enerjisi biriktirir.", "passive_level": 10,
		"ultimate": "Emilen Güç", "ultimate_text": "Emdiği saldırılar ultisini hazırlar. Ultinin saldırı biçimini birlikte belirleyeceğiz.", "ultimate_gate": "10. seviye • Emme ile dolar", "legendary_level": 0},
	{"name": "Kıyat", "description": "Uzaktan okçu\nYerden ok yağmuru", "hp": 80.0, "speed": 232.0, "damage": 29.0, "reach": 300.0, "period": 0.50, "weapon": "bow", "color": Color("8eae65"),
		"ratings": {"damage": 50, "speed": 60, "attack_speed": 70}, "style": "Uzaktan okçuluk", "passive": "10. seviyeyi geçince rastgele efsanevi yetenekler sunulur.", "passive_level": 11,
		"ultimate": "Yeraltı Okları", "ultimate_text": "Ulti dolduğunda yerden oklar yükseltir ve düşmanları vurur.", "ultimate_gate": "Ulti enerjisi dolduğunda", "legendary_level": 11},
	{"name": "Yelme", "description": "Uzun mızrak\nSeri saplama", "hp": 110.0, "speed": 218.0, "damage": 33.0, "reach": 125.0, "period": 0.54, "weapon": "spear", "color": Color("669bc0"),
		"ratings": {"damage": 50, "speed": 40, "attack_speed": 45}, "style": "Uzun mızrak", "passive": "Uzun mızrağıyla mesafesini koruyarak saldırır.", "passive_level": 1,
		"ultimate": "Mızrak Fırtınası", "ultimate_text": "Art arda çok hızlı mızrak vuruşları gerçekleştirir.", "ultimate_gate": "Ulti enerjisi dolduğunda", "legendary_level": 0},
	{"name": "Çura", "description": "Ağır savaşçı\nYıkıcı darbeler", "hp": 155.0, "speed": 196.0, "damage": 43.0, "reach": 85.0, "period": 0.77, "weapon": "hammer", "color": Color("cf9563"),
		"ratings": {"damage": 75, "speed": 30, "attack_speed": 40}, "style": "Ağır yakın dövüş", "passive": "Yavaş hareketine karşılık güçlü darbelerle savaşır.", "passive_level": 1,
		"ultimate": "Yıkım Yağmuru", "ultimate_text": "Seri şekilde ağır hasar veren darbeler yağdırır.", "ultimate_gate": "Ulti enerjisi dolduğunda", "legendary_level": 0}
]

# ratings: agreed 0–100 design values. Legacy speed/damage/period above remain
# prototype combat units until the final gameplay balancing milestone.
