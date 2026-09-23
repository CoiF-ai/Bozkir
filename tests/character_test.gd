extends SceneTree
const Sprites = preload("res://scripts/character_sprites.gd")
var checks := 0
var failures := 0
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	Sprites.setup()
	for hero in range(7):
		for state in Sprites.definitions[hero]:
			var data := Sprites.frames(hero,state)
			for texture in data.list:
				check(texture != null and texture.get_width()>0,"Frame loads")
				if texture is AtlasTexture: check(Rect2(Vector2.ZERO,texture.atlas.get_size()).encloses(texture.region),"Frame stays within sheet")
	check(Sprites.pet_for(0,20)==-1 and Sprites.pet_for(0,21)==5,"Alp pet after 20")
	check(Sprites.pet_for(1,29)==-1 and Sprites.pet_for(1,30)==6,"Kam pet at 30")
	check(Sprites.pet_for(2,60)==-1,"Kiyat no pet")
	check(Sprites.pet_for(3,21)==5 and Sprites.pet_for(4,21)==5,"Temporary hobbits")
	var game = load("res://scenes/main.tscn").instantiate()
	game.audio_enabled = false
	game.profile_path = ""
	game.score_path = ""
	root.add_child(game)
	game.set_process(false)
	game._start()
	game.selected_hero=1
	game.level=30
	game._update_character_visuals(0.01)
	check(game.shield_time>0,"Kam shield activates")
	var health: float = game.hp
	game.shots.append({"pos":game.player,"velocity":Vector2.ZERO,"life":1.0,"radius":3.0,"damage":20.0})
	game._update_shots(0.01)
	check(game.hp==health and game.shots.is_empty(),"Shield absorbs projectile")
	game._hurt(10)
	check(game.hp<health,"Shield does not block melee")
	game._finish(false)
	check(is_instance_valid(game.death_screen) and game.mode=="lost","Death screen shown")
	var screen = game.death_screen
	screen.activate("restart")
	screen.activate("menu")
	check(screen.transitioning and screen.buttons[0].disabled,"Transition blocks repeated click")
	await create_timer(0.85).timeout
	check(game.mode=="play" and game.level==1 and game.shield_time==0,"Crack finishes then restart resets run")
	game.queue_free()
	await process_frame
	print("CHARACTER TESTS: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
