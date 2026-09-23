extends SceneTree
const E = preload("res://scripts/encounter_rules.gd")
const Art = preload("res://scripts/enemy_sprites.gd")
var checks := 0
var failures := 0
func check(ok: bool, message: String) -> void:
	checks+=1
	if not ok: failures+=1; push_error(message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	Art.frames("zombie","idle")
	for key in Art.manifest:
		for state in ["idle","run","attack","death"]:
			var data := Art.frames(key,state)
			check(not data.list.is_empty(),"Animation exists")
			for texture in data.list:
				if texture is AtlasTexture: check(Rect2(Vector2.ZERO,texture.atlas.get_size()).encloses(texture.region),"Frame within sheet")
	for floor_id in range(3):
		var boss := E.stats(floor_id,3,0,1,10)
		check(is_equal_approx(boss.damage,50*E.BOSS_RATINGS[floor_id][0]/100.0),"Boss damage rating")
		check(is_equal_approx(boss.speed,120*E.BOSS_RATINGS[floor_id][2]/100.0),"Boss speed rating")
	var low := E.stats(0,0,0,1,1)
	var high := E.stats(0,0,0,30,20)
	check(high.hp>low.hp and high.speed>low.speed and high.damage>low.damage,"Zombies scale with wave and level")
	check(E.stats(0,2,1,1,1).damage>E.stats(0,2,0,1,1).damage,"Red exceeds white")
	check(E.stats(2,7,0,30,10,true).speed>E.stats(2,7,0,30,10,false).speed,"Final wizard frenzy")
	var game=load("res://scenes/main.tscn").instantiate()
	game.profile_path=""
	game.score_path=""
	game.audio_enabled=false
	root.add_child(game)
	game.set_process(false)
	game._start()
	game.level=80
	game._complete_floor()
	check(game.mode=="play" and game.floor_index==0,"Level alone never completes floor")
	game.wave=9
	game._update_encounter(0.1)
	check(not game.ritual_ready,"No altar before wave 10")
	game.wave=10
	game._update_encounter(0.1)
	check(game.ritual_ready and not game.boss_active,"Wave 10 reveals altar, no automatic boss")
	game._interact_encounter()
	check(not game.boss_active,"Cannot summon remotely")
	game.player=game.ritual_position
	game._interact_encounter()
	check(game.boss_active and game.enemies.size()==1,"Nearby interaction summons boss")
	game._interact_encounter()
	check(game.enemies.size()==1,"Boss cannot be summoned twice")
	game.boss_elapsed=239
	game._update_encounter(0.5)
	check(not game.horde_active,"No early timeout horde")
	game._update_encounter(0.5)
	check(game.horde_active and game.enemies.size()>1,"240 seconds triggers horde")
	game.enemies[0].hp=0
	game._reap_enemies()
	check(game.portal_active and game.boss_defeated and game.mode=="play","Boss kill opens portal without transition")
	check(game.portal_position.distance_to(game.player)>650,"Portal is elsewhere")
	game._complete_floor()
	check(game.floor_index==0,"Cannot use portal remotely")
	game.player=game.portal_position
	game._interact_encounter()
	check(game.mode=="floor_clear","Entering portal completes floor")
	game._advance_floor()
	check(game.floor_index==1 and not game.portal_active and not game.horde_active,"Second floor resets encounter")
	game.floor_index=2
	game.wave=10
	game._update_encounter(0.1)
	game.player=game.ritual_position
	game._interact_encounter()
	game._update_encounter(0.1)
	check(game.boss_active and game.horde_active and game.enemies.size()>=7,"Final summon immediately includes wizard, demons and spirits")
	for enemy in game.enemies:
		if enemy.kind==3: enemy.hp=0
	game._reap_enemies()
	game.player=game.portal_position
	game._interact_encounter()
	check(game.mode=="won","Final portal wins campaign")
	game.queue_free()
	await process_frame
	print("ENCOUNTER TESTS: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
