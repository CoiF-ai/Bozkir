extends SceneTree
const Catalog=preload("res://scripts/defense_catalog.gd")
const Loot=preload("res://scripts/chest_loot.gd")
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	checks+=1
	if not ok: failures+=1; push_error(message)
func run() -> void:
	var ids := {}
	for hero in range(5):
		var count := 0
		for tier in range(4):
			for item in Catalog.pool(hero,tier):
				check(not ids.has(item.id),"Unique catalog id")
				ids[item.id]=true
				check(item.hero==hero and item.tier==tier and item.power>0 and item.radius>0,"Valid hero, tier and behavior")
				count+=1
		check(count==100,"100 defense items per hero")
	check(ids.size()==500,"Exactly 500 defense items")
	var rng := RandomNumberGenerator.new()
	rng.seed=3129
	var found := {}
	var eligible := true
	for hero in range(5):
		for i in range(1500):
			var item := Loot.roll(hero,30,rng)
			eligible=eligible and item.hero in [-1,hero]
			if item.get("defense",false): found[item.family]=true
	check(eligible and found.size()==10,"Chests roll all ten families with hero filtering")
	var game=load("res://scenes/main.tscn").instantiate()
	game.audio_enabled=false; game.profile_path=""; game.score_path=""
	root.add_child(game)
	game.set_process(false)
	game._start()
	game.player=Vector2.ZERO
	game.mode="chest"
	game.pending_loot=Catalog.item(0,0,0)
	game._claim_loot()
	check(game.defenses.modules.has(0) and game.inventory.size()==1,"Claim equips real defense")
	var hp: float=game.hp
	game._hurt(10)
	check(game.hp==hp and game.defenses.shield<game.defenses.shield_capacity,"Shield absorbs incoming damage")
	game.defenses.reset()
	game.defenses.equip(Catalog.item(0,6,0))
	game.shots.append({"pos":Vector2(15,0),"velocity":Vector2.ZERO,"life":3.0,"damage":30.0,"radius":5.0})
	game._update_shots(0.01)
	check(game.shots.is_empty() and game.defenses.charges==2,"Ward consumes a charge and destroys projectile")
	game.defenses.reset()
	game.defenses.equip(Catalog.item(0,7,0))
	game.hp=50
	game.defenses.update(game,0.1)
	check(game.hp>50 and game.hp<=game.max_hp,"Totem heals within max HP")
	for family in [1,2,3,4,5,8,9]:
		game.defenses.reset()
		game.defenses.equip(Catalog.item(0,family,0))
		game.enemies.clear()
		game._spawn(0,Vector2(45,0))
		var enemy: Dictionary=game.enemies[0]
		enemy.emerge=0; enemy.hp=10000
		if family==4: game.defenses.retaliate(game)
		else:
			for i in range(120): game.defenses.update(game,1.0/60)
		check(enemy.hp<10000,"Family %d deals actual damage"%family)
		if family==3: check(enemy.get("slow_time",0)>0,"Frost applies movement slow")
		if family==9: check(enemy.pos.x>45,"Shockwave pushes enemy away")
	game.defenses.reset()
	for i in range(20): game.defenses.equip(Catalog.item(0,1,i%10))
	check(game.defenses.modules.size()==1 and game.defenses.modules[1].stacks==3,"Duplicate family aggregation capped")
	game._start()
	check(game.defenses.modules.is_empty() and game.defenses.shield==0,"Restart clears all defenses")
	game.queue_free()
	await process_frame
	print("DEFENSE: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
