extends RefCounted
const L = preload("res://scripts/localization.gd")
const HEROES := ["Alp","Kam","Kıyat","Yelme","Çura"]
const FAMILIES := ["Kut Kalkanı","Döner Tornado","Alev Fırlatıcı","Buz Halkası","Diken Zırhı","Döner Bıçaklar","Mermi Siperi","Şifa Totemi","Yıldırım Zinciri","İtme Dalgası"]
const VARIANTS := ["Bakır","Çevik","Geniş","Demir","Yoğun","Sürekli","Gümüş","Uzak","Ezici","Göksel"]
const TIERS := [0,0,0,1,1,1,2,2,2,3]
const EFFECTS := ["Yenilenen kalkan hasarı emer.","Çevrende döner, yakındaki düşmanları iter ve yaralar.","En yakın düşmana yönelen alev konisi yakar.","Buz patlaması düşmanları yavaşlatır.","Darbe alınca yakındaki düşmanlara hasar yansıtır.","Üç bıçak çevrende dönerek temas hasarı verir.","Yakındaki düşman mermilerini tüketilen yüklerle engeller.","Belirli aralıklarla can yeniler.","Yakındaki üç düşmana yıldırım sıçratır.","Düşmanları geri savuran alan patlaması yaratır."]
static func item(hero: int, family: int, variant: int) -> Dictionary:
	var tier: int = TIERS[variant]
	var level := 1.0+tier*0.6
	# Variant profiles trade radius, strength and activation interval, not just names.
	var power: float = (12.0+family*1.2)*level*[1.0,0.8,0.75,1.1,1.4,0.85,1.25,0.9,1.5,1.8][variant]
	var radius: float = (72.0+family*5)*[1.0,0.9,1.5,1.05,0.8,1.1,1.2,1.7,0.9,1.4][variant]
	var period: float = [5.5,0.5,0.3,3.0,0.0,0.15,6.0,6.0,2.2,3.5][family]*[1.0,0.65,1.1,0.95,1.2,0.65,0.85,1.1,1.25,0.75][variant]
	if hero==0 and family in [0,4,6]: power*=1.2
	if hero==1 and family in [1,3,8]: power*=1.2
	if hero==2: radius*=1.15
	if hero==3: period*=0.85
	if hero==4: power*=1.15; period*=1.1
	return {"id":"def_%d_%d_%d"%[hero,family,variant],"hero":hero,"tier":tier,"name":"%s • %s %s"%[HEROES[hero],L.t(VARIANTS[variant]),L.t(FAMILIES[family])],"icon":Vector2i(6+family%5,5+family/5),"damage":0.0,"speed":0.0,"rate":0.0,"health":0,"reach":0,"luck":0,"defense":true,"family":family,"power":power,"radius":radius,"period":period,"rank":tier*10+variant}
static func pool(hero: int, tier: int) -> Array[Dictionary]:
	var result: Array[Dictionary]=[]
	for family in range(10):
		for variant in range(10):
			if TIERS[variant]==tier: result.append(item(hero,family,variant))
	return result
static func description(data: Dictionary) -> String:
	return L.t(EFFECTS[data.family])+"\n"+L.t("Güç %.1f • Alan %.0f • Aralık %.2f sn")%[data.power,data.radius,data.period]+"\n"+L.t("Her türün en güçlüsü çalışır; ek buluntular en fazla 3 yığın, yığın başına +%15 güç verir.")
