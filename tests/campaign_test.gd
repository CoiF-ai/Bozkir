extends SceneTree
const Rules = preload("res://scripts/campaign_rules.gd")
const Economy = preload("res://scripts/run_economy.gd")
const Library = preload("res://scripts/audio_library.gd")
var checks := 0
var failures := 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: " + message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	for floor_id in range(3):
		check(Rules.FLOORS[floor_id].power==[0.5,0.75,1.0][floor_id],"Floor stock value")
	for kind in range(4):
		var second := Rules.enemy_stats(1, kind)
		var third := Rules.enemy_stats(2, kind)
		for key in ["hp", "speed", "damage", "attack_rate"]:
			check(is_equal_approx(second[key], third[key] * 0.75), "Floor 2 %s is 75 percent for kind %d" % [key, kind])
			check(is_equal_approx(third[key], Rules.MAX_ENEMIES[kind][key]), "Floor 3 %s equals fixed ceiling" % key)
	var money := Economy.new()
	check(not money.buy_chest() and money.coins == 0, "Insufficient funds do not buy or spend")
	money.coins = 300
	for price in [20, 40, 80, 160]:
		check(money.chest_price() == price and money.buy_chest(), "Chest doubles to %d" % price)
	check(money.coins == 0 and money.chest_price() == 320, "Four chests charge exactly 300 gold")
	var first_gold := money.gold_drop(0)
	money.floor_index = 1
	check(money.gold_drop(0) > first_gold, "Gold income increases with floor")
	money.reset()
	money.kills = 14
	check(not money.healing_ready(0), "Healing locked before kill threshold")
	money.kills = 15
	check(money.consume_healing(0), "Healing unlocks at 15 kills")
	check(not money.healing_ready(0) and money.heal_targets[0] == 40, "Healing recharges via 25 additional kills")
	for track in Library.MENU_TRACKS:
		var stream: AudioStream = load(track)
		check(stream != null and stream.get_length() > 1, "Menu music imports: " + track.get_file())
	for event in Library.SOUNDS:
		for path in Library.SOUNDS[event]:
			check(ResourceLoader.exists(path), "Sound binding resolves: " + event)
	# Headless controller checks only: no rendered gameplay or player session.
	var game = load("res://scenes/main.tscn").instantiate()
	game.profile_path = ""
	game.score_path = ""
	game.audio_enabled = false
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game._start()
	game._spawn(0, Vector2(50, 0))
	game.enemies[0].hp = 0
	game._reap_enemies()
	check(game.gems.size() == 1 and game.coin_drops.size() == 1, "Every enemy drops both XP and gold")
	game.player = game.coin_drops[0].pos
	game._update_coins(0.1)
	check(game.economy.coins > 0 and game.coin_drops.is_empty(), "Coin pickup credits wallet")
	game.economy.coins = 100
	var chest: Dictionary = game.chests[0]
	game._open_chest(chest)
	check(game.mode == "chest_offer" and game.economy.coins == 100, "Chest requires purchase confirmation")
	game._purchase_chest(chest)
	check(game.economy.coins == 80 and chest.opened, "Purchase consumes exact price once")
	game._purchase_chest(chest)
	check(game.economy.coins == 80, "Double purchase cannot charge twice")
	game._claim_loot()
	game.level = 20
	game.elapsed = 120
	game.boss_defeated=true
	game.portal_active=true
	game.portal_position=game.player
	game._complete_floor()
	check(game.mode == "floor_clear" and game.completed_chapters == 1, "Defeated boss and portal complete floor")
	game.boss_defeated=true
	game.portal_active=true
	game.portal_position=game.player
	game._complete_floor()
	check(game.completed_chapters == 1, "Repeat completion cannot grant extra unlock")
	game._continue_as(1)
	check(game.floor_index == 1 and game.level == 20 and game.selected_hero == 1 and game.economy.coins == 80, "Transition preserves level, gold and selected new hero")
	game.level = 40
	game.elapsed = 240
	game.boss_defeated=true
	game.portal_active=true
	game.portal_position=game.player
	game._complete_floor()
	game._advance_floor()
	check(game.floor_index == 2 and game.economy.chest_price() == 40, "Chest escalation carries between floors")
	game.level = 60
	game.elapsed = 360
	game.boss_defeated=true
	game.portal_active=true
	game.portal_position=game.player
	game._complete_floor()
	check(game.mode == "won", "Final portal ends campaign")
	game.queue_free()
	await process_frame
	print("CAMPAIGN TESTS: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
