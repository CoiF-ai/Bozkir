extends RefCounted
const FLOORS := [
	{"name": "Gök Ormanı", "power": 0.50, "gold": 1.0, "sky": Color("80bdd1"), "ground": Color("50774d"), "rock": Color("3b5947"), "accent": Color("abd57d")},
	{"name": "Kristal Derinlik", "power": 0.75, "gold": 2.0, "sky": Color("17243e"), "ground": Color("334c67"), "rock": Color("202d46"), "accent": Color("77d8e4")},
	{"name": "Kızıl Hisar", "power": 1.00, "gold": 4.0, "sky": Color("773f3c"), "ground": Color("6b5446"), "rock": Color("3d3541"), "accent": Color("ecac70")}
]
# Baseline stock values. Runtime growth and boss overrides live in encounter_rules.gd.
const MAX_ENEMIES = preload("res://scripts/encounter_rules.gd").BASE

const HEAL_KILLS := [15, 40, 80, 130, 200]
const HEAL_RECHARGE_KILLS := 25

static func enemy_stats(floor_index: int, kind: int) -> Dictionary:
	var floor_data: Dictionary = FLOORS[clampi(floor_index, 0, 2)]
	var result: Dictionary = MAX_ENEMIES[clampi(kind, 0, 7)].duplicate()
	for key in ["hp", "speed", "damage", "attack_rate"]:
		result[key] *= floor_data.power
	result.xp = ceili(result.xp * (1 + floor_index * 0.8))
	return result
