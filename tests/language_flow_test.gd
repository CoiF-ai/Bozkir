extends SceneTree
const L = preload("res://scripts/localization.gd")
const Library = preload("res://scripts/audio_library.gd")
const Roster = preload("res://scripts/roster.gd")
var checks := 0
var failures := 0
var cfg_path := "user://language_flow_test.cfg"
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	L.set_locale("unknown")
	check(L.locale == "tr" and L.t("PLAY")=="OYNA","Turkish default and invalid locale fallback")
	L.set_locale("en")
	check(L.t("SETTINGS  /  AYARLAR")=="SETTINGS","English translation")
	for hero in Roster.HEROES:
		for field in ["style","passive","ultimate","ultimate_text","ultimate_gate","description"]:
			check(L.t(hero[field])!=hero[field],"Hero field translated: "+field)
	check(Library.MENU_TRACKS.size()==8,"Eight menu tracks")
	for i in range(2): check(load(Library.MENU_TRACKS[i]) is AudioStreamMP3,"New MP3 imported")
	var cfg := ConfigFile.new()
	cfg.set_value("interface","language","en")
	cfg.set_value("audio","music",0.22)
	cfg.set_value("audio","effects",0.44)
	cfg.save(cfg_path)
	var menu = load("res://scenes/menu.tscn").instantiate()
	menu.settings_path = cfg_path
	menu.progress_path = ""
	menu.score_path = ""
	menu.audio_enabled = false
	root.add_child(menu)
	current_scene = menu
	await process_frame
	check(L.locale=="en" and menu.play_button.caption=="PLAY","Saved English loaded on startup")
	menu._show_settings()
	check(menu.language_picker.selected==1,"English selection visible")
	menu._change_language(0)
	await process_frame
	await process_frame
	check(L.locale=="tr" and menu.play_button.caption=="OYNA","Turkish change rebuilds UI")
	check(is_equal_approx(menu.music_volume,0.22) and is_equal_approx(menu.effect_volume,0.44),"Language change retains volumes")
	var saved := ConfigFile.new()
	saved.load(cfg_path)
	check(saved.get_value("interface","language")=="tr","Language persisted")
	menu._change_language(1)
	await process_frame
	await process_frame
	menu._close_popup()
	menu._play_preview()
	await process_frame
	var game = current_scene
	game.set_process(false)
	check(game.launch_from_menu and game.mode=="play","Play goes directly to first floor")
	check(game.level==1 and game.floor_index==0 and game.selected_hero==0,"Correct initial campaign state")
	game._refresh_hud()
	check("WAVE" in game.wave_label.text and "HP" in game.status.text,"English gameplay HUD")
	game._pause()
	check(game.mode=="pause","Pause available after menu launch")
	game.queue_free()
	await process_frame
	DirAccess.remove_absolute(ProjectSettings.globalize_path(cfg_path))
	L.set_locale("tr")
	print("LANGUAGE/FLOW TESTS: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
