extends RefCounted
const L = preload("res://scripts/localization.gd")
const Defense = preload("res://scripts/defense_catalog.gd")
const NAMES := [["Alp Kılıcı","Oba Kalkanı","Yıldırım Çeliği","Gök Savaşçısı"],["Kam Asası","Karanlık Mühür","Ruh Kristali","Göğün Sırrı"],["Kıyat Oku","Avcı Yayı","Ay Sadakı","Yeraltı Yayı"],["Yelme Ucu","Akıncı Mızrağı","Fırtına Kargısı","Gök Mızrağı"],["Çura Çekici","Demir Eldiven","Dağ Kıran","Demir Yemini"]]
const TIERS := ["Regular","Epic","Legend","Destansı"]
const COLORS := [Color("c4c5ad"),Color("c3a1df"),Color("e0c573"),Color("dc9479")]
# Sprite-sheet coordinates are display assets only; behavior is defined below.
const ICONS := [Vector2i(10,9),Vector2i(6,5),Vector2i(11,9),Vector2i(12,9),Vector2i(11,13)]
static func odds(luck: float) -> Array[float]:
	var value := clampf(luck,0,60)
	return [70-value*0.7,22+value*0.35,7+value*0.25,1+value*0.1]
static func item(hero: int, tier: int) -> Dictionary:
	var data := {"id":"%d_%d" % [hero,tier],"hero":hero,"tier":tier,"name":NAMES[hero][tier],"icon":ICONS[hero],"damage":0.08+tier*0.07,"speed":-0.02 if tier==1 else 0.0,"rate":0.04*tier,"health":0,"reach":0,"luck":0}
	match hero:
		0: data.health = 8+tier*7
		1: data.reach = 12+tier*8
		2: data.rate = 0.08+tier*0.06; data.damage = 0.04+tier*0.03
		3: data.reach = 8+tier*5; data.rate = 0.04+tier*0.04
		4: data.damage = 0.15+tier*0.08; data.speed = -0.02*tier
	if hero==0 and tier==1: data.grants_shield=true
	return data
static func charm(tier: int) -> Dictionary:
	return {"id":"luck_%d"%tier,"hero":-1,"tier":tier,"name":"Şans Boncuğu" if tier==0 else "Kutlu Tılsım","icon":Vector2i(8+tier,11),"damage":0.0,"speed":0.0,"rate":0.0,"health":0,"reach":0,"luck":4 if tier==0 else 9}
static func roll(hero: int, luck: float, rng: RandomNumberGenerator) -> Dictionary:
	var weights := odds(luck)
	var value := rng.randf()*100
	var tier := 3
	for i in range(4):
		value -= weights[i]
		if value<0:
			tier=i
			break
	if tier<2 and rng.randf()<0.25: return charm(tier)
	if rng.randf()<0.8:
		var pool := Defense.pool(clampi(hero,0,4),tier)
		return pool[rng.randi_range(0,pool.size()-1)]
	return item(clampi(hero,0,4),tier)
static func icon(data: Dictionary) -> Texture2D:
	if data.get("defense",false): return load("res://assets/defense-icons/%d.svg"%data.family)
	var atlas := AtlasTexture.new()
	atlas.atlas = load("res://assets/raven/16x16.png")
	atlas.region = Rect2(Vector2(data.icon)*16,Vector2(16,16))
	return atlas
static func description(data: Dictionary) -> String:
	if data.get("defense",false): return Defense.description(data)
	if data.get("grants_shield",false): return Defense.description(Defense.item(0,0,3))+"\n"+L.t("Can +%d • Menzil +%d")%[data.health,data.reach]
	if data.luck>0: return L.t("Şans +%d (en fazla 60)")%data.luck
	return L.t("Hasar +%d%% • Saldırı hızı +%d%% • Hareket %d%%")%[roundi(data.damage*100),roundi(data.rate*100),roundi(data.speed*100)]+L.t("\nCan +%d • Menzil +%d")%[data.health,data.reach]

