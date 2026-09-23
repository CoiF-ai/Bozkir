extends SceneTree
const Loot = preload("res://scripts/chest_loot.gd")
const Markers = preload("res://scripts/trail_markers.gd")
var checks := 0
var failures := 0
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error(label)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 91621
	check(Markers.flags().size()>100 and Markers.valid_flag("invalid")=="TR","Flag catalog and fallback")
	for luck in [0,30,60,999]:
		var rates := Loot.odds(luck)
		check(is_equal_approx(rates[0]+rates[1]+rates[2]+rates[3],100),"Odds sum to 100")
	check(Loot.odds(60)[3]>Loot.odds(0)[3],"Luck improves mythic chance")
	var pools_valid := true
	var seen := {}
	for hero in range(5):
		for i in range(1000):
			var item := Loot.roll(hero,30,rng)
			pools_valid = pools_valid and item.hero in [-1,hero]
			seen[item.id]=true
	check(pools_valid and seen.size()>100,"Only eligible hero/shared items; expanded pool reachable")
	var path := "user://test_death_mark.cfg"
	check(Markers.save_death(path,1,Vector2(345,-123),"TR")==OK,"Death marker saved")
	var death := Markers.read_death(path)
	check(death.floor==1 and death.pos==Vector2(345,-123),"Death location reloads accurately")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	var game = load("res://scenes/main.tscn").instantiate()
	game.audio_enabled=false
	game.profile_path=""
	game.score_path=""
	root.add_child(game)
	game.set_process(false)
	game._start()
	game.player=Vector2(200,100)
	game._place_marker()
	game.player=Vector2(-500,50)
	game._place_marker()
	game._place_marker()
	check(game.placed_markers.size()==2 and game.placed_markers[0].pos==Vector2(200,100),"Exactly two placements at player position")
	game.mode="pause"
	game._place_marker()
	check(game.placed_markers.size()==2,"No placement while paused")
	game.mode="floor_clear"
	game._advance_floor()
	check(game.placed_markers.size()==2,"Floor transition does not refill placement charges")
	game.selected_hero=4
	game.economy.coins=100
	game._open_chest(game.chests[0])
	game._purchase_chest(game.chests[0])
	check(game.pending_loot.hero in [-1,0],"Reward uses starting hero after hero change")
	game.pending_loot=Loot.item(0,2)
	var damage: float=game.damage
	var health: float=game.max_hp
	game._claim_loot()
	check(game.damage>damage and game.max_hp>health and game.inventory.size()==1,"Item stats apply to gameplay")
	game._claim_loot()
	check(game.inventory.size()==1,"Reward cannot be claimed twice")
	game.mode="chest"
	game.pending_loot=Loot.charm(1)
	game._claim_loot()
	check(game.luck==9,"Luck item improves stat")
	game._finish(false)
	check(game.last_death.pos==game.player and game.placed_markers.size()==2,"Death marker does not consume charge")
	game._start()
	check(game.inventory.is_empty() and game.luck==0 and game.placed_markers.is_empty(),"New run resets items, luck and charges")
	game.queue_free()
	await process_frame
	print("MARKER/LOOT TESTS: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
