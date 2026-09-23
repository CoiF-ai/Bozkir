extends SceneTree
const Roster = preload("res://scripts/roster.gd")
const Items = preload("res://scripts/item_catalog.gd")
const Scores = preload("res://scripts/scoreboard.gd")
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
	var values := [[65, 45, 30], [55, 65, 45], [50, 60, 70], [50, 40, 45], [75, 30, 40]]
	var names := ["Alp", "Kam", "Kıyat", "Yelme", "Çura"]
	for i in range(5):
		var hero: Dictionary = Roster.HEROES[i]
		check(hero.name == names[i] and [hero.ratings.damage, hero.ratings.speed, hero.ratings.attack_speed] == values[i], "Hero %d matches agreed identity and ratings" % i)
	check(Roster.HEROES[1].passive_level == 10, "Kam absorption begins at level ten")
	check(Roster.HEROES[2].legendary_level == 11, "Kiyat legendary skills require exceeding level ten")
	for rarity in Items.RARITIES:
		check(Items.by_rarity(rarity.id).size() == 2, "Each item rarity has two examples")
	var base: Dictionary = Roster.HEROES[0].ratings
	var modified := Items.modified_ratings(base, ["steppe_boots", "cracked_seal"])
	check(modified.speed == 53 and modified.damage == 61 and modified.attack_speed == 22, "Benefits and drawbacks combine correctly")
	check(base.damage == 65 and base.speed == 45, "Item previews do not mutate base ratings")
	check(Items.modified_ratings(base, ["iron_oath", "sky_seal"]).damage == 100, "Item previews respect 100-point ceiling")
	var path := "user://menu_score_test_%d.cfg" % Time.get_ticks_usec()
	var book := Scores.new()
	book.path = path
	book.read()
	check(book.records.is_empty(), "Missing score file shows no invented scores")
	check(book.add_completion(1, 0, 280.5) == OK, "Valid completion saved")
	book.add_completion(1, 0, 300)
	check(book.records.size() == 1 and book.records[0].seconds == 280.5, "Slower completion cannot replace personal best")
	book.add_completion(1, 0, 275.123)
	book.add_completion(2, 1, 310)
	var loaded := Scores.new()
	loaded.path = path
	loaded.read()
	check(loaded.records.size() == 2 and loaded.records[0].seconds == 275.123, "Scores persist and sort by elapsed seconds")
	check(book.add_completion(0, 0, -4) == ERR_INVALID_DATA, "Invalid results rejected")
	check(book.add_completion(1, 20, INF) == ERR_INVALID_DATA, "Invalid hero and non-finite time rejected")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	var menu = load("res://scenes/menu.tscn").instantiate()
	menu.audio_enabled = false
	menu.settings_path = ""
	menu.progress_path = ""
	menu.score_path = ""
	root.add_child(menu)
	await process_frame
	menu.set_process(false)
	check(menu.cards.size() == 5, "Five portraits visible")
	for i in range(5):
		menu._preview_character(i)
		check(menu.info_name.text == names[i].to_upper() and menu.rating_bars[0].value == values[i][0], "Preview updates portrait data including locked characters")
	check(menu.selected_hero == 0, "Locked previews cannot select unavailable hero")
	for bar in menu.rating_bars:
		check(bar.size.y < 12, "Rating bars do not overlap next label")
	check(menu.play_button.caption == "OYNA", "Turkish play action is visible")
	menu._close_popup()
	menu._show_items()
	check(menu.popup_kind == "items" and menu.veil.visible, "Item atlas opens")
	menu._close_popup()
	menu._show_scores()
	check(menu.scores.records.is_empty() and menu.popup_kind == "scores", "Scoreboard opens in honest empty state")
	menu._close_popup()
	menu._show_settings()
	menu.music_slider.value = 23
	menu.effects_slider.value = 0
	check(is_equal_approx(menu.music_volume, 0.23) and menu.click_sound.volume_db == -80, "Audio sliders update actual players")
	check(menu.music.stream is AudioStreamMP3 and not menu.music.stream.loop, "Playlist track can finish and advance")
	menu._play_track(7)
	menu._next_track()
	check(menu.track_index == 0, "Eight-track playlist wraps to War Drums")
	menu._close_popup()
	menu._toggle_mute()
	check(menu.music.volume_db == -80, "Mute silences menu music")
	menu.queue_free()
	await process_frame
	print("MENU TESTS: %d checks, %d failures; gameplay never loaded" % [checks, failures])
	quit(1 if failures else 0)
