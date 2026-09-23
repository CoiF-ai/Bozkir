extends RefCounted
## First balance draft. Items are catalogued here; world drops come later.
const RARITIES := [
	{"id": "regular", "name": "REGULAR", "color": Color("c4c5ad")},
	{"id": "epic", "name": "EPIC", "color": Color("c3a1df")},
	{"id": "legend", "name": "LEGEND", "color": Color("e0c573")},
	{"id": "destansi", "name": "DESTANSI", "color": Color("dc9479")}
]
const ITEMS := [
	{"id": "steppe_boots", "name": "Bozkır Çizmesi", "rarity": "regular", "benefit": "Hız +8", "cost": "Hasar −4", "mods": {"speed": 8, "damage": -4}},
	{"id": "cracked_seal", "name": "Çatlak Mühür", "rarity": "regular", "benefit": "Lanetli öğe", "cost": "Saldırı hızı −8", "mods": {"attack_speed": -8}},
	{"id": "storm_bead", "name": "Fırtına Boncuğu", "rarity": "epic", "benefit": "Hasar +12", "cost": "Hız −6", "mods": {"damage": 12, "speed": -6}},
	{"id": "wind_bracer", "name": "Yel Bileziği", "rarity": "epic", "benefit": "Saldırı hızı +14", "cost": "Hasar −5", "mods": {"attack_speed": 14, "damage": -5}},
	{"id": "wolf_standard", "name": "Kurt Sancağı", "rarity": "legend", "benefit": "Hasar +10 · Hız +10", "cost": "Dezavantaj yok", "mods": {"damage": 10, "speed": 10}},
	{"id": "moon_quiver", "name": "Ay Sadakı", "rarity": "legend", "benefit": "Saldırı hızı +20", "cost": "Hız −8", "mods": {"attack_speed": 20, "speed": -8}},
	{"id": "sky_seal", "name": "Gök Mührü", "rarity": "destansi", "benefit": "Hasar +22 · Hız +12", "cost": "Dezavantaj yok", "mods": {"damage": 22, "speed": 12}},
	{"id": "iron_oath", "name": "Demir Yemini", "rarity": "destansi", "benefit": "Hasar +30", "cost": "Hız −15 · Saldırı hızı −10", "mods": {"damage": 30, "speed": -15, "attack_speed": -10}}
]

static func by_rarity(id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item in ITEMS:
		if item.rarity == id:
			result.append(item)
	return result

static func modified_ratings(base: Dictionary, item_ids: Array) -> Dictionary:
	var result := base.duplicate(true)
	for item in ITEMS:
		if item.id in item_ids:
			for key in item.mods:
				result[key] += item.mods[key]
	for key in result:
		result[key] = clampi(result[key], 0, 100)
	return result
