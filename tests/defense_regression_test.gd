extends SceneTree
const Catalog=preload("res://scripts/defense_catalog.gd")
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	checks+=1
	if not ok: failures+=1; push_error(message)
func run() -> void:
	var game=load("res://scenes/main.tscn").instantiate()
	game.audio_enabled=false; game.profile_path=""; game.score_path=""
	root.add_child(game); game.set_process(false); game._start(); game.player=Vector2.ZERO
	for hero in range(5):
		for variant in range(10):
			game.defenses.reset(); game.enemies.clear()
			game.defenses.equip(Catalog.item(hero,5,variant))
			for distance in [5.0,25.0,60.0]:
				game._spawn(0,Vector2(distance,0)); game.enemies[-1].emerge=0; game.enemies[-1].hp=1000
			game.defenses.update(game,0.2)
			for enemy in game.enemies: check(enemy.hp<1000,"Every blade variant hits close-range enemies")
	game.defenses.reset()
	game.defenses.equip(Catalog.item(0,0,0),game.max_hp)
	var capacity: float=game.defenses.shield_capacity
	check(capacity>40,"Baseline shield withstands multiple small hits")
	game.hp=100; game.immunity=0
	game._hurt(capacity+10)
	check(is_equal_approx(game.hp,90) and game.defenses.shield==0,"Only overflow damages health")
	game.defenses.update(game,6)
	check(game.defenses.shield==capacity,"Depleted shield regenerates")
	game.mode="chest"; game.pending_loot=game.Loot.item(0,1); game._claim_loot()
	check(game.defenses.modules.has(0) and game.defenses.shield>0,"Legacy Oba shield grants functional protection")
	game.economy.reset()
	check(game.economy.gold_drop(0)==6,"Starting zombie grants 6 gold instead of 2")
	check(game.economy.chest_price()==20,"Starting chest price remains 20")
	game.queue_free(); await process_frame
	print("DEFENSE REGRESSION: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
