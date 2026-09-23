extends RefCounted
const Rules = preload("res://scripts/campaign_rules.gd")
var coins := 0
var chests_opened := 0
var kills := 0
var floor_index := 0
var heal_targets: Array[int] = []

func _init() -> void:
	reset()

func reset() -> void:
	coins = 0
	chests_opened = 0
	kills = 0
	floor_index = 0
	heal_targets.assign(Rules.HEAL_KILLS)

func gold_multiplier() -> float:
	return Rules.FLOORS[floor_index].gold * (1 + chests_opened * 0.15)

func gold_drop(kind: int) -> int:
	return maxi(1, ceili(Rules.MAX_ENEMIES[kind].gold * gold_multiplier() * 3.0))

func chest_price() -> int:
	return 20 * (1 << mini(chests_opened, 40))

func buy_chest() -> bool:
	var price := chest_price()
	if coins < price:
		return false
	coins -= price
	chests_opened += 1
	return true

func healing_ready(index: int) -> bool:
	return index >= 0 and index < heal_targets.size() and kills >= heal_targets[index]

func consume_healing(index: int) -> bool:
	if not healing_ready(index):
		return false
	heal_targets[index] = kills + Rules.HEAL_RECHARGE_KILLS
	return true
