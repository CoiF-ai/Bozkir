extends Node2D
const L = preload("res://scripts/localization.gd")
## Campaign controller: asset animations, wave encounters and portal progression.
const TouchPad = preload("res://scripts/touch_pad.gd")
const Roster = preload("res://scripts/roster.gd")
const MiniMap = preload("res://scripts/minimap.gd")
const Scores = preload("res://scripts/scoreboard.gd")
const Rules = preload("res://scripts/campaign_rules.gd")
const Economy = preload("res://scripts/run_economy.gd")
const EnvironmentArt = preload("res://scripts/environment_art.gd")
const BattleAudio = preload("res://scripts/battle_audio.gd")
const Sprites = preload("res://scripts/character_sprites.gd")
const DeathScreen = preload("res://scripts/death_screen.gd")
var sprite_state := "idle"
var sprite_clock := 0.0
var hurt_anim := 0.0
var pet_position := Vector2.ZERO
var pet_moving := false
var shield_time := 0.0
var shield_cooldown := 0.0
var death_screen: Control
const Markers = preload("res://scripts/trail_markers.gd")
const Loot = preload("res://scripts/chest_loot.gd")
const DefenseSystem = preload("res://scripts/defense_system.gd")
var defenses := DefenseSystem.new()
const HeroMotion = preload("res://scripts/hero_motion.gd")
var hero_motion := HeroMotion.new()
var sprite_flip := false
var attack_direction := Vector2.RIGHT
var shield_status: Label
var selected_flag := "TR"
var marker_path := "user://bozkir_markers.cfg"
var placed_markers: Array[Dictionary] = []
var last_death: Dictionary = {}
var marker_button: Button
var inventory_button: Button
var starting_hero := 0
var luck := 0.0
var inventory: Array[Dictionary] = []
var pending_loot: Dictionary = {}
const Encounters = preload("res://scripts/encounter_rules.gd")
const EnemyArt = preload("res://scripts/enemy_sprites.gd")
var ritual_position := Vector2.ZERO
var ritual_ready := false
var boss_active := false
var boss_defeated := false
var boss_elapsed := 0.0
var horde_active := false
var horde_cd := 0.0
var portal_position := Vector2.ZERO
var portal_active := false
var encounter_button: Button
var scaling_cd := 0.0
var corpses: Array[Dictionary] = []
var queued_summons: Array[Dictionary] = []
const ARENA := Rect2(-2100, -1300, 4200, 2600)
const WAVE_SECONDS := 22.0
const SIM_STEP := 1.0 / 60.0
var simulation_remainder := 0.0
var hud_countdown := 0.0
var vision_material: ShaderMaterial
var vision_overlay: ColorRect
var night_active := false
const DAY_SECONDS := 180.0
const DASH_COOLDOWN := 3.0

const UPGRADES := [
	["Savaşçı Gücü", "Saldırı hasarı +%25", "damage"],
	["Alp Refleksi", "Saldırı aralığı −%15", "rate"],
	["Uzanış", "Vuruş menzili +14", "reach"],
	["Bozkır Adımı", "Hareket hızı +%12", "speed"],
	["Yaşam Özü", "Azami can +25, can yenile +40", "health"],
	["Ruh Çekimi", "Deneyim toplama alanı +35", "magnet"]
]
var rng := RandomNumberGenerator.new()
var launch_from_menu := false
var launch_hero := 0
var mode := "title"
var player := Vector2.ZERO
var facing := Vector2.RIGHT
var hp := 100.0
var max_hp := 100.0
var speed := 145.0
var damage := 23.0
var reach := 79.0
var attack_period := 0.65
var attack_cd := 0.0
var immunity := 0.0
var dash_cd := 0.0
var dash_left := 0.0
var dash_direction := Vector2.RIGHT
var magnet := 70.0
var xp := 0
var level := 1
var kills := 0
var wave := 1
var wave_time := 0.0
var elapsed := 0.0
var spawn_cd := 1.0
var banner_left := 0.0
var enemies: Array[Dictionary] = []
var shots: Array[Dictionary] = []
var gems: Array[Dictionary] = []
var effects: Array[Dictionary] = []
var scenery: Array[Dictionary] = []
var camera: Camera2D
var ui: Control
var pad: Control
var status: Label
var wave_label: Label
var health_bar: ProgressBar
var xp_bar: ProgressBar
var boss_bar: ProgressBar
var boss_label: Label
var banner: Label
var ability: Button
var pause_button: Button
var modal: PanelContainer
var modal_stack: VBoxContainer
var overlay: ColorRect
var ui_time := 0.0
var completed_chapters := 0
var chapter := 1
var selected_hero := 0
var profile_path := "user://bozkir_progress.cfg"
var score_path := "user://bozkir_scores.cfg"
var save_error := false
var moving := false
var walk_phase := 0.0
var movement_direction := Vector2.RIGHT
var attack_anim := 0.0
var day_tint: CanvasModulate
var sun_label: Label
var hint_label: Label
var notice_left := 0.0
var notice := ""
var hero_shots: Array[Dictionary] = []
var fountains: Array[Dictionary] = []
var chests: Array[Dictionary] = []
var lanterns: Array[PointLight2D] = []
var trails: Array[Dictionary] = []
var last_trail := 0.0
var economy := Economy.new()
var floor_index := 0
var floor_start_time := 0.0
var boss_spawned := false
var coin_drops: Array[Dictionary] = []
var audio_enabled := true
var battle_audio: Node
var footstep_cd := 0.0

func _ready() -> void:
	rng.randomize()
	_load_progress()
	_generate_scenery()
	day_tint = CanvasModulate.new()
	add_child(day_tint)
	camera = Camera2D.new()
	add_child(camera)
	_build_ui()
	get_viewport().size_changed.connect(_layout_phone)
	_layout_phone()
	battle_audio = BattleAudio.new()
	battle_audio.enabled = audio_enabled
	add_child(battle_audio)
	_create_lanterns()
	_update_daylight()
	if launch_from_menu:
		selected_hero = clampi(launch_hero,0,mini(completed_chapters,4))
		_save_progress()
		_start()
	else: _title()
	queue_redraw()

func _layout_phone() -> void:
	var safe := preload("res://scripts/phone_layout.gd").safe_rect(get_viewport())
	_apply_safe_layout(safe)

func _apply_safe_layout(safe: Rect2) -> void:
	var view := get_viewport_rect()
	ui.offset_left=safe.position.x
	ui.offset_top=safe.position.y
	ui.offset_right=safe.end.x-view.size.x
	ui.offset_bottom=safe.end.y-view.size.y

func _generate_scenery() -> void:
	var decor := RandomNumberGenerator.new()
	decor.seed = 72419
	for i in range(1700):
		scenery.append({"pos": Vector2(decor.randf_range(-1770, 1770), decor.randf_range(-1090, 1090)), "kind": decor.randi_range(0, 4)})

func _build_ui() -> void:
	var vision_layer := CanvasLayer.new()
	vision_layer.layer = 1
	add_child(vision_layer)
	vision_overlay = ColorRect.new()
	vision_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vision_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vision_material = ShaderMaterial.new()
	vision_material.shader = preload("res://scripts/vision.gdshader")
	vision_overlay.material = vision_material
	vision_layer.add_child(vision_overlay)
	var layer := CanvasLayer.new()
	layer.layer = 2
	add_child(layer)
	ui = Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(ui)
	var theme := Theme.new()
	theme.default_font_size = 17
	ui.theme = theme
	var top := ColorRect.new()
	top.color = Color(0.035, 0.07, 0.09, 0.94)
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.offset_bottom = 76
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(top)
	status = _label(ui, "", 15, Color("dbe6cc"))
	status.position = Vector2(24, 10)
	health_bar = _bar(ui, Color("c97b69"))
	health_bar.position = Vector2(24, 37)
	health_bar.size = Vector2(222, 8)
	xp_bar = _bar(ui, Color("64cfb8"))
	xp_bar.position = Vector2(24, 53)
	xp_bar.size = Vector2(222, 5)
	shield_status = _label(ui,"",10,Color("91dcf2"))
	shield_status.position = Vector2(24,61)
	wave_label = _label(ui, "", 17, Color("e2cf9b"))
	wave_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	wave_label.offset_left = -160
	wave_label.offset_right = 160
	wave_label.offset_top = 12
	wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_button = _button(L.t("II  DURAKLAT"), _pause)
	ui.add_child(pause_button)
	pause_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	pause_button.offset_left = -168
	pause_button.offset_right = -20
	pause_button.offset_top = 16
	pause_button.offset_bottom = 57
	sun_label = _label(ui, "", 13, Color("b9c6a4"))
	sun_label.position = Vector2(24, 82)
	var map := MiniMap.new()
	map.game = self
	ui.add_child(map)
	hint_label = _label(ui, "", 14, Color("d6dab8"))
	hint_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	hint_label.offset_left = -290
	hint_label.offset_right = 290
	hint_label.offset_top = -43
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_label = _label(ui, L.t("TEPEGÖZ • OBANIN LANETİ"), 14, Color("edac83"))
	boss_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	boss_label.offset_left = -220
	boss_label.offset_right = 220
	boss_label.offset_top = 82
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_bar = _bar(ui, Color("bf695d"))
	boss_bar.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	boss_bar.offset_left = -180
	boss_bar.offset_right = 180
	boss_bar.offset_top = 105
	boss_bar.offset_bottom = 112
	pad = TouchPad.new()
	ui.add_child(pad)
	ability = _button(L.t("ATIL\nHAZIR  [BOŞLUK]"), _dash)
	ui.add_child(ability)
	ability.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	ability.offset_left = -161
	ability.offset_right = -27
	ability.offset_top = -125
	ability.offset_bottom = -39
	ability.add_theme_font_size_override("font_size", 16)
	marker_button = _button("",_place_marker)
	ui.add_child(marker_button)
	marker_button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	marker_button.offset_left = -161
	marker_button.offset_right = -27
	marker_button.offset_top = -191
	marker_button.offset_bottom = -137
	marker_button.add_theme_font_size_override("font_size",14)
	inventory_button = _button(L.t("ÇANTA [I]"),_show_inventory)
	ui.add_child(inventory_button)
	inventory_button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	inventory_button.offset_left = -161
	inventory_button.offset_right = -27
	inventory_button.offset_top = -247
	inventory_button.offset_bottom = -202
	inventory_button.add_theme_font_size_override("font_size",14)
	encounter_button = _button("",_interact_encounter)
	ui.add_child(encounter_button)
	encounter_button.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	encounter_button.offset_left=-140
	encounter_button.offset_right=140
	encounter_button.offset_top=-108
	encounter_button.offset_bottom=-60
	encounter_button.add_theme_font_size_override("font_size",16)
	banner = _label(ui, "", 24, Color("f1d8a0"))
	banner.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	banner.offset_left = -360
	banner.offset_right = 360
	banner.offset_top = 131
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay = ColorRect.new()
	overlay.color = Color(0.015, 0.035, 0.045, 0.84)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.add_child(overlay)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center)
	modal = PanelContainer.new()
	modal.custom_minimum_size.x = 510
	var box := StyleBoxFlat.new()
	box.bg_color = Color("11232b")
	box.border_color = Color("647a66")
	box.set_border_width_all(2)
	box.content_margin_left = 32
	box.content_margin_right = 32
	box.content_margin_top = 24
	box.content_margin_bottom = 24
	modal.add_theme_stylebox_override("panel", box)
	center.add_child(modal)
	modal_stack = VBoxContainer.new()
	modal_stack.add_theme_constant_override("separation", 12)
	modal.add_child(modal_stack)

func _label(parent: Node, value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = L.t(value)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _bar(parent: Node, color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	var back := StyleBoxFlat.new()
	back.bg_color = Color("293b40")
	bar.add_theme_stylebox_override("fill", fill)
	bar.add_theme_stylebox_override("background", back)
	parent.add_child(bar)
	return bar

func _button(value: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = value
	button.custom_minimum_size.y = 45
	button.focus_mode = Control.FOCUS_NONE
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("203b40")
	normal.border_color = Color("548b80")
	normal.set_border_width_all(1)
	normal.content_margin_left = 15
	normal.content_margin_right = 15
	var hover := normal.duplicate()
	hover.bg_color = Color("345853")
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_color_override("font_color", Color("e5e7cf"))
	button.pressed.connect(action)
	return button

func _clear_modal(title: String, subtitle: String) -> void:
	if is_instance_valid(battle_audio):
		battle_audio.pause_streams(true)
	pad.reset()
	pad.hide()
	overlay.show()
	for child in modal_stack.get_children():
		modal_stack.remove_child(child)
		child.queue_free()
	var heading := _label(modal_stack, title, 33, Color("dfcc9c"))
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var description := _label(modal_stack, subtitle, 16, Color("aec5bc"))
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _return_main_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _title() -> void:
	_clear_modal("B O Z K I R", L.t("S O N   A L P\n\nUnutulmuş Oba • Oynanabilir prototip"))
	_label(modal_stack, L.t("Zombiler. Çürük ağaçlar. Kurt sürüleri. Tepegöz.\n10 dalga boyunca obayı savun."), 17, Color("e2e6cc"))
	modal_stack.add_child(_button(L.t("KARAKTER SEÇ   →"), _character_select.bind(completed_chapters + 1)))
	_label(modal_stack, L.t("WASD / yön tuşları: hareket  •  Boşluk: atıl\nSaldırı otomatik  •  Esc: duraklat\nDokunmatik: sol joystick + sağ ATIL butonu"), 14, Color("8aa69e"))

func _start() -> void:
	_reset_encounter()
	starting_hero = selected_hero
	luck = 0
	inventory.clear()
	defenses.reset()
	pending_loot.clear()
	placed_markers.clear()
	last_death = Markers.read_death(marker_path) if not profile_path.is_empty() else {}
	if is_instance_valid(death_screen): death_screen.queue_free()
	sprite_state = "idle"
	sprite_clock = 0
	hurt_anim = 0
	shield_time = 0
	shield_cooldown = 0
	pet_position = Vector2.ZERO
	floor_index = 0
	chapter = 1
	floor_start_time = 0
	boss_spawned = false
	economy.reset()
	coin_drops.clear()
	footstep_cd = 0
	var hero: Dictionary = Roster.HEROES[selected_hero]
	player = Vector2.ZERO
	facing = Vector2.RIGHT
	sprite_flip = false
	attack_direction = Vector2.RIGHT
	hp = hero.hp
	max_hp = hero.hp
	speed = hero.speed
	damage = hero.damage
	reach = hero.reach
	attack_period = hero.period
	moving = false
	walk_phase = 0
	attack_anim = 0
	movement_direction = Vector2.RIGHT
	notice_left = 0
	last_trail = 0
	attack_cd = 0
	immunity = 0
	dash_cd = 0
	dash_left = 0
	magnet = 70
	xp = 0
	level = 1
	kills = 0
	wave = 1
	wave_time = 0
	elapsed = 0
	spawn_cd = 0.6
	enemies.clear()
	shots.clear()
	gems.clear()
	effects.clear()
	hero_shots.clear()
	trails.clear()
	_reset_supplies()
	camera.position = player
	_update_daylight()
	_resume()
	_wave_banner()
	battle_audio.start_floor(floor_index)

func _resume() -> void:
	mode = "play"
	simulation_remainder = 0.0
	overlay.hide()
	pad.reset()
	pad.show()
	if is_instance_valid(battle_audio):
		battle_audio.pause_streams(false)

func _pause() -> void:
	if mode == "pause":
		_resume()
	elif mode == "play":
		mode = "pause"
		_clear_modal(L.t("SOLUKLAN"), L.t("Oba seni bekliyor. Süre durduruldu."))
		modal_stack.add_child(_button(L.t("DEVAM ET"), _resume))
		modal_stack.add_child(_button(L.t("YENİDEN BAŞLA"), _start))
		modal_stack.add_child(_button(L.t("ANA MENÜ"), _return_main_menu))

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and mode == "play" and is_instance_valid(ui):
		_pause()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_P:
			_pause()
		elif event.keycode == KEY_E:
			_interact_encounter()
		elif event.keycode == KEY_F:
			_place_marker()
		elif event.keycode == KEY_I:
			_show_inventory()
		elif event.keycode == KEY_SPACE:
			_dash()

func _input(event: InputEvent) -> void:
	# Handle the second finger directly: regular mouse emulation tracks one touch.
	if event is InputEventScreenTouch and event.pressed and mode == "play":
		if encounter_button.visible and encounter_button.get_global_rect().has_point(event.position):
			_interact_encounter()
			get_viewport().set_input_as_handled()
		elif marker_button.get_global_rect().has_point(event.position):
			_place_marker()
			get_viewport().set_input_as_handled()
		elif inventory_button.get_global_rect().has_point(event.position):
			_show_inventory()
			get_viewport().set_input_as_handled()
		elif ability.get_global_rect().has_point(event.position):
			_dash()
			get_viewport().set_input_as_handled()
		elif pause_button.get_global_rect().has_point(event.position):
			_pause()
			get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	ui_time += delta
	_advance_simulation(delta)
	if mode in ["play","lost"]: _update_character_visuals(minf(delta,0.25))
	_update_vision()
	hud_countdown -= delta
	if hud_countdown <= 0:
		_refresh_hud()
		_update_daylight()
		hud_countdown = 0.1
	queue_redraw()

func _advance_simulation(delta: float) -> void:
	if mode != "play":
		simulation_remainder = 0.0
		return
	# Keep game speed independent of render FPS; bound long app-resume stalls.
	simulation_remainder += minf(delta, 0.25)
	while simulation_remainder + 0.000001 >= SIM_STEP and mode == "play":
		simulation_remainder -= SIM_STEP
		_simulate(SIM_STEP)
	if mode != "play": simulation_remainder = 0.0

func _simulate(dt: float) -> void:
	elapsed += dt
	var now_night := _is_night()
	if now_night != night_active:
		night_active = now_night
		scaling_cd = 0
		spawn_cd = minf(spawn_cd,_spawn_interval())
		notice = L.t("Gece akını! Düşmanlar hızlandı; çevreni kolla.") if now_night else L.t("Gün doğdu. Gece öfkesi sona erdi.")
		notice_left = 6
	wave_time += dt
	banner_left = maxf(0, banner_left - dt)
	immunity = maxf(0, immunity - dt)
	attack_cd -= dt
	attack_anim = maxf(0, attack_anim - dt)
	notice_left = maxf(0, notice_left - dt)
	dash_cd = maxf(0, dash_cd - dt)
	var movement := Vector2(
		float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),
		float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)))
	if pad.direction.length() > 0.1:
		movement = pad.direction
	movement = movement.limit_length(1)
	moving = movement.length() > 0.1
	if movement.length() > 0.1:
		facing = movement.normalized()
		if absf(facing.x)>0.1: sprite_flip = facing.x<0
		movement_direction = facing
		walk_phase += dt * 19 * movement.length()
	if dash_left > 0:
		hero_motion.advance(self,movement,dt)
	else:
		player += movement * speed * dt
	_update_trails(dt)
	footstep_cd -= dt
	if moving and dash_left <= 0 and footstep_cd <= 0:
		battle_audio.play_event("footstep", 0.3)
		footstep_cd = 0.28
	player = player.clamp(ARENA.position + Vector2(25, 25), ARENA.end - Vector2(25, 25))
	camera.position = camera.position.lerp(player, 1.0 - exp(-9 * dt))
	if wave_time >= WAVE_SECONDS:
		wave += 1
		wave_time = 0
	_update_encounter(dt)
	spawn_cd -= dt
	if spawn_cd <= 0:
		spawn_cd = _spawn_interval()
		_spawn_group()
	defenses.update(self,dt)
	_reap_enemies()
	_update_enemies(dt)
	if mode != "play":
		return
	_auto_attack()
	if mode != "play":
		return
	_update_shots(dt)
	if mode != "play":
		return
	_update_hero_shots(dt)
	if mode != "play":
		return
	_update_supplies(dt)
	if mode != "play":
		return
	_update_gems(dt)
	_update_coins(dt)
	for i in range(effects.size() - 1, -1, -1):
		effects[i].life -= dt
		if effects[i].life <= 0:
			effects.remove_at(i)

func _wave_banner() -> void:
	banner_left = 3.3
	banner.text = L.t("%s • DALGA %d") % [L.t(Rules.FLOORS[floor_index].name).to_upper(),wave]

func _spawn_group() -> void:
	if enemies.size() >= 100: return
	_spawn(6 if floor_index==2 else 0)
	if _is_night(): _spawn(6 if floor_index==2 else 0)
	if wave>=3 and wave<=5: _spawn(1,Vector2.INF,rng.randi_range(0,2))
	if wave>=5:
		var variant := 0 if wave<7 else 1
		var center := _spawn_position()
		_spawn(2,center+Vector2(60,0),variant)
		if wave>=9 and rng.randf()<0.25:
			_spawn(2,center,2)
			for i in range(3): _spawn(2,center+Vector2.from_angle(i*TAU/3)*45,variant)
	if wave>5 and rng.randf()<0.25: _spawn(1,Vector2.INF,rng.randi_range(0,2))
	if floor_index==2 and wave>=6 and level>=30 and rng.randf()<0.18: _spawn(7)

func _spawn_position() -> Vector2:
	var angle := rng.randf_range(0, TAU)
	return (player + Vector2.from_angle(angle) * rng.randf_range(340, 450)).clamp(ARENA.position + Vector2(45, 45), ARENA.end - Vector2(45, 45))

func _spawn(kind: int, location := Vector2.INF, variant := 0) -> void:
	if enemies.size()>=120 and kind!=3: return
	var stats := _enemy_stats(kind,variant)
	var radius: float = [12,17,23 if variant==2 else 17,34,17,15,15,26][kind]
	var pos := _spawn_position() if location == Vector2.INF else location.clamp(ARENA.position + Vector2(45, 45), ARENA.end - Vector2(45, 45))
	enemies.append({"variant":variant,"anim":rng.randf(),"attack_visual":0.0,"summon_cd":8.0,"kind": kind, "pos": pos, "hp": stats.hp, "max_hp": stats.hp,
		"speed": stats.speed, "damage": stats.damage, "attack_rate": stats.attack_rate, "contact_cd": 0.0,
		"xp": stats.xp, "gold": economy.gold_drop(kind), "radius": radius, "emerge": 0.9, "cooldown": rng.randf_range(1.0, 2.2),
		"windup": 0.0, "action": "", "target": player, "charge": 0.0, "dir": Vector2.RIGHT,
		"flash": 0.0, "dash_hit": false})

func _update_enemies(dt: float) -> void:
	for enemy in enemies:
		enemy.anim += dt
		enemy.slow_time = maxf(0,enemy.get("slow_time",0.0)-dt)
		var slow_factor := 0.55 if enemy.slow_time>0 else 1.0
		enemy.attack_visual = maxf(0,enemy.attack_visual-dt)
		enemy.summon_cd -= dt
		enemy.flash = maxf(0, enemy.flash - dt)
		if enemy.emerge > 0:
			enemy.emerge -= dt
			continue
		var offset: Vector2 = player - enemy.pos
		var distance := offset.length()
		var toward := offset.normalized()
		enemy.cooldown -= dt
		enemy.contact_cd = maxf(0, enemy.contact_cd - dt)
		if enemy.windup > 0:
			# Ranged monsters track the player instead of becoming stationary turrets.
			if enemy.kind in [1,7] and distance > enemy.radius + 35:
				enemy.pos += toward * enemy.speed * 0.45 * dt * slow_factor
				enemy.dir = toward
			enemy.windup -= dt
			if enemy.windup <= 0:
				_execute_enemy_attack(enemy)
		elif enemy.charge > 0:
			enemy.charge -= dt
			enemy.pos += enemy.dir * enemy.speed * 2.05 * dt * slow_factor
		else:
			var move_speed: float = enemy.speed * slow_factor
			if enemy.kind in [1,7] and distance < 215:
				move_speed *= 0.75
			if distance > enemy.radius + 13:
				enemy.pos += toward * move_speed * dt
			if enemy.cooldown <= 0:
				if enemy.kind == 1:
					_prepare(enemy, "branch" if distance < 82 else "throw", 0.85)
				elif enemy.kind == 2 and distance < 265:
					_prepare(enemy, "pounce", 0.65)
				elif enemy.kind == 3:
					_prepare(enemy,"slam" if distance<135 else "pounce",0.38)
				elif enemy.kind == 7:
					_prepare(enemy,"slam" if distance<140 else "boulder",0.85)
				elif enemy.kind in [4,5,6] and distance<180:
					_prepare(enemy,"pounce",0.45)
				elif enemy.kind==0 and distance<36:
					_prepare(enemy,"branch",0.5)
		if enemy.kind==7 and enemy.summon_cd<=0:
			enemy.summon_cd=10.0 if not boss_active else 5.0
			for j in range(3): queued_summons.append({"kind":5,"pos":enemy.pos+Vector2.from_angle(j*TAU/3)*45})
		if player.distance_to(enemy.pos) < enemy.radius + 13 and enemy.windup <= 0 and enemy.contact_cd <= 0 and immunity <= 0:
			_hurt(enemy.damage)
			enemy.contact_cd = 1.0 / enemy.attack_rate
		if dash_left > 0 and selected_hero in [0,2] and not enemy.dash_hit and player.distance_to(enemy.pos) < enemy.radius + 30:
			enemy.dash_hit = true
			enemy.hp -= damage * 1.8
			enemy.flash = 0.15
		enemy.pos = enemy.pos.clamp(ARENA.position + Vector2(20, 20), ARENA.end - Vector2(20, 20))
		if mode != "play":
			return
	for summon in queued_summons: _spawn(summon.kind,summon.pos)
	queued_summons.clear()
	_reap_enemies()

func _prepare(enemy: Dictionary, action: String, duration: float) -> void:
	enemy.action = action
	enemy.windup = duration / maxf(0.5,enemy.attack_rate)
	enemy.anim = 0
	enemy.attack_visual = enemy.windup+0.5
	enemy.target = player
	enemy.dir = (player - enemy.pos).normalized()

func _execute_enemy_attack(enemy: Dictionary) -> void:
	match enemy.action:
		"throw", "boulder":
			var heavy: bool = enemy.action == "boulder"
			shots.append({"pos": enemy.pos, "velocity": enemy.dir * (240 if heavy else 165), "damage": enemy.damage, "radius": 13 if heavy else 7, "life": 5.0})
			enemy.cooldown = 1.0 / enemy.attack_rate
		"pounce":
			enemy.charge = 0.6
			enemy.cooldown = 1.0 / enemy.attack_rate
		"branch", "slam":
			var radius := 125.0 if enemy.action == "slam" else 82.0
			if enemy.action == "slam":
				_effect(enemy.pos, radius, Color("e29a69"), 0.35)
				battle_audio.play_event("heavy_hit", 0.8)
			if player.distance_to(enemy.pos) < radius + 12:
				_hurt(enemy.damage)
			enemy.cooldown = 1.0 / enemy.attack_rate

func _auto_attack() -> void:
	if attack_cd > 0:
		return
	var closest := reach + 32
	var target := Vector2.INF
	for enemy in enemies:
		var distance := player.distance_to(enemy.pos)
		if enemy.emerge <= 0 and distance < closest and distance <= reach + enemy.radius:
			closest = distance
			target = enemy.pos
	if target == Vector2.INF:
		return
	var direction := (target - player).normalized()
	attack_direction = direction
	if not moving:
		facing = direction
		if absf(facing.x)>0.1: sprite_flip=facing.x<0
	attack_cd = attack_period
	attack_anim = minf(attack_period,0.6)
	sprite_clock = 0
	var weapon: String = Roster.HEROES[selected_hero].weapon
	battle_audio.play_event(weapon, 0.65)
	if weapon == "bow":
		hero_shots.append({"pos": player, "velocity": direction * 510, "life": (reach + 40) / 510.0, "damage": damage})
		return
	elif weapon == "pulse":
		hero_shots.append({"pos":player,"velocity":direction*350,"life":(reach+40)/350.0,"damage":damage,"magic":true})
		return
	else:
		effects.append({"pos": player, "radius": reach, "color": Color("e3e8b0"), "life": 0.18, "angle": direction.angle()})
	for enemy in enemies:
		var offset: Vector2 = enemy.pos - player
		var in_arc: bool = weapon == "pulse" or offset.normalized().dot(direction) > (0.83 if weapon == "spear" else 0.1)
		if enemy.emerge <= 0 and offset.length() < reach + enemy.radius and in_arc:
			enemy.hp -= damage
			enemy.flash = 0.16
			if enemy.kind != 3:
				enemy.pos += offset.normalized() * 9
	_reap_enemies()

func _reap_enemies() -> void:
	for i in range(enemies.size() - 1, -1, -1):
		var enemy: Dictionary = enemies[i]
		if enemy.hp <= 0:
			var corpse: Dictionary = enemy.duplicate()
			corpse.life=0.8
			corpses.append(corpse)
			if enemy.kind==3: _boss_killed()
			kills += 1
			economy.kills = kills
			gems.append({"pos": enemy.pos, "xp": enemy.xp})
			coin_drops.append({"pos": enemy.pos + Vector2(10, 0), "value": economy.gold_drop(enemy.kind) * (3 if enemy.kind==2 and enemy.variant==2 else 1)})
			enemies.remove_at(i)

func _update_shots(dt: float) -> void:
	for i in range(shots.size() - 1, -1, -1):
		var shot: Dictionary = shots[i]
		shot.pos += shot.velocity * dt
		shot.life -= dt
		if defenses.intercept(shot.pos,player):
			_effect(shot.pos,15,Color("bb91ef"),0.15)
			shots.remove_at(i)
			continue
		if shield_time > 0 and player.distance_to(shot.pos) < 40 + shot.radius:
			_effect(shot.pos,18,Color("9870da"),0.25)
			shots.remove_at(i)
			continue
		if player.distance_to(shot.pos) < 13 + shot.radius:
			_hurt(shot.damage)
			shots.remove_at(i)
		elif shot.life <= 0:
			shots.remove_at(i)

func _update_gems(dt: float) -> void:
	for i in range(gems.size() - 1, -1, -1):
		var gem: Dictionary = gems[i]
		if player.distance_to(gem.pos) < magnet:
			gem.pos = gem.pos.move_toward(player, 240 * dt)
		if player.distance_to(gem.pos) < 17:
			xp += gem.xp
			gems.remove_at(i)
	if xp >= _xp_needed():
		_level_up()

func _xp_needed() -> int:
	return 12 + (level - 1) * 9

func _level_up() -> void:
	xp -= _xp_needed()
	level += 1
	mode = "upgrade"
	_clear_modal(L.t("GÜÇLEN • SEVİYE %d") % level, L.t("Bir armağan seç. Seçim sırasında oyun durur."))
	_upgrade_choices()

func _upgrade_choices() -> void:
	var choices: Array = range(UPGRADES.size())
	choices.shuffle()
	for i in range(3):
		var upgrade: Array = UPGRADES[choices[i]]
		modal_stack.add_child(_button(L.t(upgrade[0]) + "  ·  " + L.t(upgrade[1]), _choose_upgrade.bind(upgrade[2])))

func _choose_upgrade(kind: String) -> void:
	match kind:
		"damage": damage *= 1.25
		"rate": attack_period = maxf(0.18, attack_period * 0.85)
		"reach": reach += 14
		"speed": speed *= 1.12
		"health":
			max_hp += 25
			hp = minf(max_hp, hp + 40)
		"magnet": magnet += 35
	_resume()
	if xp >= _xp_needed():
		_level_up()

func _dash() -> void:
	if mode != "play" or dash_cd > 0:
		return
	hero_motion.begin(self)
	_effect(player, 32, Color("60d5c8"), 0.3)
	battle_audio.play_event("dash", 0.55)

func _hurt(amount: float) -> void:
	if immunity > 0 or mode != "play":
		return
	defenses.retaliate(self)
	var shield_before := defenses.shield
	amount = defenses.absorb(amount)
	if defenses.shield < shield_before: _effect(player,34,Color("84dff5"),0.2)
	if amount<=0:
		immunity=0.25
		return
	hurt_anim = 0.24
	hp = maxf(0, hp - amount)
	immunity = 0.7
	_effect(player, 23, Color("e68b78"), 0.22)
	battle_audio.play_event("hurt", 0.7)
	if hp <= 0:
		_finish(false)

func _finish(won: bool) -> void:
	if mode == "won" or mode == "lost":
		return
	mode = "won" if won else "lost"
	if not won:
		last_death = {"pos":player,"floor":floor_index,"flag":selected_flag}
		if not profile_path.is_empty():
			if Markers.save_death(marker_path,floor_index,player,selected_flag)!=OK:
				push_warning("Death marker could not be saved")
		modal.hide()
		battle_audio.music.stop()
		for voice in battle_audio.voices: voice.stop()
		death_screen = DeathScreen.new()
		death_screen.sound_enabled = audio_enabled
		ui.add_child(death_screen)
		death_screen.chosen.connect(_death_action)
		return
	var unlock := ""
	if won and chapter > completed_chapters:
		completed_chapters = chapter
		if chapter < Roster.HEROES.size():
			unlock = L.t("\nYeni karakter açıldı: ") + Roster.HEROES[chapter].name
		else:
			unlock = L.t("\nTüm karakterler açık. Yolculuk devam ediyor.")
		_save_progress()
	_clear_modal(L.t("OBA KURTULDU") if won else L.t("SAVAŞÇI DÜŞTÜ"), L.t("Bölüm %d  •  Dalga %d  •  Seviye %d\n%d düşman  •  Süre %02d:%02d%s") % [chapter, wave, level, kills, int(elapsed) / 60, int(elapsed) % 60, unlock])
	if save_error:
		_label(modal_stack, L.t("Kayıt yazılamadı; ilerleme bu oturumda korunuyor."), 14, Color("edac83"))
	if won:
		modal_stack.add_child(_button(L.t("YENİ YOLCULUK • KARAKTER SEÇ"), _character_select.bind(1)))
	else:
		modal_stack.add_child(_button(L.t("AYNI KARAKTERLE YENİDEN DENE"), _start))
		modal_stack.add_child(_button(L.t("KARAKTER DEĞİŞTİR"), _character_select.bind(chapter)))

func _effect(point: Vector2, radius: float, color: Color, life: float) -> void:
	effects.append({"pos": point, "radius": radius, "color": color, "life": life})

func _refresh_hud() -> void:
	encounter_button.visible = mode=="play" and ((ritual_ready and not boss_spawned and player.distance_to(ritual_position)<90) or (portal_active and player.distance_to(portal_position)<75))
	encounter_button.text = L.t("PORTALA GİR [E]") if portal_active else L.t("BOSS ÇAĞIR [E]")
	boss_label.text = (L.t("Son Büyücü").to_upper() if floor_index==2 else "YELBEĞEN")+" • "+(L.t("AKIN BAŞLADI") if horde_active else "%02d:%02d"%[int(maxf(0,240-boss_elapsed))/60,int(maxf(0,240-boss_elapsed))%60])
	marker_button.text = L.t("BAYRAK + KEDİ %d/2\n[F]") % (2-placed_markers.size())
	marker_button.disabled = mode!="play" or placed_markers.size()>=2
	inventory_button.disabled = mode!="play"
	status.text = L.t("%s • SV %02d   %d/%d CAN") % [Roster.HEROES[selected_hero].name.to_upper(), level, ceili(hp), int(max_hp)]
	shield_status.text = L.t("KALKAN %d/%d • Yenilenme %.1f sn")%[ceili(defenses.shield),ceili(defenses.shield_capacity),maxf(0,defenses.modules[0].cooldown)] if defenses.modules.has(0) else ""
	health_bar.max_value = max_hp
	health_bar.value = hp
	xp_bar.max_value = _xp_needed()
	xp_bar.value = xp
	wave_label.text = L.t("KAT %d / 3 • DALGA %d • SV %d\n%02d:%02d • %d alt edildi") % [floor_index+1,wave,level,int(elapsed)/60,int(elapsed)%60,kills]
	sun_label.text = _clock_text()
	hint_label.text = notice if notice_left > 0 else L.t("%d ALTIN  •  Sandık %d  •  Kazanç ×%.2f") % [economy.coins, economy.chest_price(), economy.gold_multiplier()]
	hint_label.visible = mode == "play"
	banner.visible = mode == "play" and banner_left > 0
	ability.text = L.t(HeroMotion.NAMES[selected_hero])+"\n"+(L.t("%.1f sn")%dash_cd if dash_cd>0 else L.t("HAZIR"))
	ability.disabled = mode != "play" or dash_cd > 0
	pause_button.disabled = mode != "play" and mode != "pause"
	boss_bar.hide()
	boss_label.hide()
	for enemy in enemies:
		if enemy.kind == 3:
			boss_bar.show()
			boss_label.show()
			boss_bar.max_value = enemy.max_hp
			boss_bar.value = enemy.hp

func _draw() -> void:
	var visible_area := Rect2(camera.position - get_viewport_rect().size * 0.5 - Vector2(100, 100), get_viewport_rect().size + Vector2(200, 200))
	EnvironmentArt.world(self, ARENA, visible_area, floor_index, elapsed)
	_draw_supplies()
	for trail in trails:
		draw_rect(Rect2(trail.pos - Vector2(8, 22), Vector2(16, 25)), Color(0.45, 0.86, 0.81, trail.life * 1.3))
	for gem in gems:
		var p: Vector2 = gem.pos
		var color := Color("e2b577") if gem.xp >= 30 else Color("62caba")
		draw_colored_polygon(PackedVector2Array([p + Vector2(0, -5), p + Vector2(4, 0), p + Vector2(0, 5), p + Vector2(-4, 0)]), color)
	for coin in coin_drops:
		draw_rect(Rect2(coin.pos - Vector2(4, 4), Vector2(8, 8)), Color("bc8744"))
		draw_rect(Rect2(coin.pos - Vector2(2, 3), Vector2(4, 6)), Color("f1d586"))
	# Draw warnings below actors so their intent remains readable.
	for enemy in enemies:
		_draw_warning(enemy)
	var actors: Array[Dictionary] = enemies.duplicate()
	actors.append({"kind": -1, "pos": player})
	actors.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.pos.y < b.pos.y)
	for actor in actors:
		if not visible_area.has_point(actor.pos): continue
		if actor.kind == -1:
			_draw_alp()
		else:
			_draw_enemy(actor)
	defenses.paint(self)
	for shot in shots:
		var r: float = shot.radius
		draw_rect(Rect2(shot.pos - Vector2(r, r), Vector2.ONE * r * 2), Color("a78c63"))
		draw_rect(Rect2(shot.pos - Vector2(r - 2, r - 2), Vector2(r, r)), Color("d2bd89"))
	for arrow in hero_shots:
		if arrow.get("magic",false):
			draw_circle(arrow.pos,7,Color("50325e"))
			draw_circle(arrow.pos,3,Color("d29bb9"))
			continue
		var direction: Vector2 = arrow.velocity.normalized()
		draw_line(arrow.pos - direction * 14, arrow.pos, Color("e5d3a1"), 3)
		draw_line(arrow.pos, arrow.pos - direction.rotated(0.6) * 7, Color("c4d7d0"), 2)
		draw_line(arrow.pos, arrow.pos - direction.rotated(-0.6) * 7, Color("c4d7d0"), 2)
	for effect in effects:
		var color: Color = effect.color
		color.a = minf(1, effect.life * 5)
		if effect.has("angle"):
			draw_arc(effect.pos, effect.radius, effect.angle - 1.35, effect.angle + 1.35, 18, color, 5)
		else:
			draw_arc(effect.pos, effect.radius, 0, TAU, 32, color, 3)

func _draw_ruin(p: Vector2) -> void:
	draw_rect(Rect2(p + Vector2(-28, 9), Vector2(64, 12)), Color("192c2c"))
	draw_rect(Rect2(p + Vector2(-21, -19), Vector2(42, 32)), Color("766b50"))
	draw_colored_polygon(PackedVector2Array([p + Vector2(-31, -16), p + Vector2(0, -45), p + Vector2(30, -16)]), Color("8f7c57"))
	draw_rect(Rect2(p + Vector2(-7, -12), Vector2(14, 25)), Color("263332"))
	var stone := p + Vector2(57, 12)
	draw_rect(Rect2(stone + Vector2(-9, -36), Vector2(18, 39)), Color("56676a"))
	draw_rect(Rect2(stone + Vector2(-3, -27), Vector2(6, 17)), Color("69a295"))
	draw_line(stone + Vector2(-6, -24), stone + Vector2(6, -15), Color("a1c6ac"), 2)

func _draw_warning(enemy: Dictionary) -> void:
	if enemy.kind == 1 or enemy.kind == 2:
		return
	var p: Vector2 = enemy.pos
	if enemy.emerge > 0:
		draw_arc(p, enemy.radius + 7, 0, TAU, 20, Color("a28f62"), 2)
		draw_line(p + Vector2(-9, 2), p + Vector2(8, -2), Color("151e1c"), 4)
	elif enemy.windup > 0:
		var warn := Color(0.92, 0.43, 0.27, 0.26 + sin(ui_time * 15) * 0.08)
		if enemy.action == "slam" or enemy.action == "branch":
			var radius := 125 if enemy.action == "slam" else 82
			draw_circle(p, radius, warn)
			draw_arc(p, radius, 0, TAU, 48, Color("eaa477"), 2)
		else:
			var length := 150 if enemy.action == "pounce" else 290
			draw_line(p, p + enemy.dir * length, warn, 20)
			draw_line(p, p + enemy.dir * length, Color("dca570"), 2)
			draw_arc(p, enemy.radius + 7, 0, TAU, 24, Color("e9b17e"), 2)

func _draw_alp() -> void:
	draw_ellipse_shadow(player)
	Sprites.paint(self,selected_hero,sprite_state,sprite_clock,player-Vector2(0,hero_motion.height(dash_left)),48,sprite_flip)
	hero_motion.paint(self)
	var tip := player+facing*25
	draw_colored_polygon(PackedVector2Array([tip+facing*7,tip-facing.rotated(0.8)*6,tip-facing.rotated(-0.8)*6]),Color(0.8,0.95,0.85,0.65))
	if attack_anim>0:
		draw_line(player+Vector2(0,-18),player+Vector2(0,-18)+attack_direction*40,Color("e4d1a3"),3)
	var pet := Sprites.pet_for(selected_hero,level)
	if pet >= 0:
		draw_ellipse_shadow(pet_position)
		Sprites.paint(self,pet,"run" if pet_moving else "idle",elapsed,pet_position,27,pet_position.x>player.x)
	if shield_time > 0:
		draw_circle(player+Vector2(0,-19),34,Color(0.23,0.07,0.4,0.25))
		draw_arc(player+Vector2(0,-19),34,0,TAU,48,Color("9870da"),3)

func draw_ellipse_shadow(at: Vector2) -> void:
	draw_rect(Rect2(at+Vector2(-13,-2),Vector2(26,5)),Color(0.02,0.03,0.05,0.4))

func _update_character_visuals(dt: float) -> void:
	hurt_anim = maxf(0,hurt_anim-dt)
	var next := "death" if mode == "lost" else "hurt" if hurt_anim>0 else ("cast" if selected_hero==1 else "attack" if selected_hero==4 else "dash") if dash_left>0 else "attack" if attack_anim>0 else "run" if moving else "idle"
	if next != sprite_state:
		sprite_state = next
		sprite_clock = 0
	else:
		var rate := 1.0
		if sprite_state == "attack":
			var data := Sprites.frames(selected_hero,"attack")
			rate = data.list.size()/data.fps/minf(attack_period,0.6)
		sprite_clock += dt*rate
	var destination := player-facing*46+Vector2(0,12)
	pet_moving = pet_position.distance_to(destination)>8
	if pet_moving: pet_position = pet_position.move_toward(destination,maxf(speed*1.25,180)*dt)
	shield_time = maxf(0,shield_time-dt)
	shield_cooldown = maxf(0,shield_cooldown-dt)
	if selected_hero == 1 and level>=30 and shield_cooldown<=0:
		shield_time = 3.0
		shield_cooldown = 10.0

func _death_action(action: String) -> void:
	if action == "restart": _start()
	else: get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _load_progress() -> void:
	if profile_path.is_empty():
		return
	var config := ConfigFile.new()
	if config.load(profile_path) != OK:
		return
	var completed: Variant = config.get_value("progress", "completed_chapters", 0)
	var hero: Variant = config.get_value("progress", "selected_hero", 0)
	completed_chapters = clampi(completed, 0, 999) if completed is int else 0
	selected_hero = clampi(hero, 0, mini(completed_chapters, Roster.HEROES.size() - 1)) if hero is int else 0
	chapter = completed_chapters + 1

func _save_progress() -> void:
	if profile_path.is_empty():
		return
	var config := ConfigFile.new()
	config.set_value("progress", "completed_chapters", completed_chapters)
	config.set_value("progress", "selected_hero", selected_hero)
	save_error = config.save(profile_path) != OK

func _hero_unlocked(index: int) -> bool:
	return index >= 0 and index < Roster.HEROES.size() and index <= completed_chapters

func _character_select(next_chapter: int) -> void:
	chapter = clampi(next_chapter, 1, completed_chapters + 1)
	mode = "select"
	_clear_modal(L.t("SAVAŞÇINI SEÇ"), L.t("Bölüm %d • Her yeni bölüm zaferinde bir karakter açılır.") % chapter)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	modal_stack.add_child(grid)
	for i in range(Roster.HEROES.size()):
		var hero: Dictionary = Roster.HEROES[i]
		var unlocked := _hero_unlocked(i)
		var title: String = ("✓ " if selected_hero == i else "") + hero.name.to_upper()
		var detail: String = L.t(hero.description) if unlocked else L.t("KİLİTLİ\nBölüm %d zaferi gerekir") % i
		var card := _button(title + "\n" + detail, _select_hero.bind(i))
		card.custom_minimum_size = Vector2(194, 95)
		card.add_theme_font_size_override("font_size", 15)
		card.disabled = not unlocked
		if selected_hero == i:
			var highlight: StyleBoxFlat = card.get_theme_stylebox("normal").duplicate()
			highlight.border_color = hero.color
			highlight.set_border_width_all(3)
			card.add_theme_stylebox_override("normal", highlight)
		grid.add_child(card)
	var active: Dictionary = Roster.HEROES[selected_hero]
	_label(modal_stack, L.t("%s  •  %d can  •  %d hız  •  %d hasar") % [active.name, active.hp, active.speed, active.damage], 16, active.color)
	modal_stack.add_child(_button(L.t("%s İLE BÖLÜM %d'E BAŞLA  →") % [active.name.to_upper(), chapter], _begin_selected))

func _select_hero(index: int) -> void:
	if not _hero_unlocked(index):
		return
	selected_hero = index
	_character_select(chapter)

func _begin_selected() -> void:
	_save_progress()
	_start()

func _day_color(time: float) -> Color:
	var colors := [Color(1.0, 0.88, 0.72), Color(1, 1, 1), Color(0.9, 0.66, 0.56), Color(0.48, 0.57, 0.78)]
	var phase := fposmod(time / DAY_SECONDS, 1.0) * 4
	var index := int(phase)
	return colors[index].lerp(colors[(index + 1) % 4], smoothstep(0, 1, phase - index))

func _is_night() -> bool:
	var hour := fposmod(6.0 + elapsed / DAY_SECONDS * 24.0,24.0)
	return hour >= 21.0 or hour < 6.0

func _spawn_interval() -> float:
	return maxf(0.65,1.9-wave*0.12-floor_index*0.2)*(0.6 if _is_night() else 1.0)

func _enemy_stats(kind: int, variant: int) -> Dictionary:
	var stats := Encounters.stats(floor_index,kind,variant,level,wave,floor_index==2 and boss_spawned)
	if _is_night():
		stats.speed *= 1.25
		stats.attack_rate *= 1.35
		stats.damage *= 1.15
	return stats

func _update_vision() -> void:
	if not is_instance_valid(vision_overlay): return
	vision_overlay.visible = mode in ["play","pause","lost","chest","chest_offer","upgrade"]
	vision_material.set_shader_parameter("view_size",get_viewport_rect().size)
	vision_material.set_shader_parameter("player_screen",get_global_transform_with_canvas()*player)
	vision_material.set_shader_parameter("radius",230.0 if _is_night() else 440.0)
	vision_material.set_shader_parameter("darkness",0.97 if _is_night() else 0.65)

func _clock_text() -> String:
	var minutes := int(fposmod(6 * 60 + elapsed / DAY_SECONDS * 1440, 1440))
	var hour := minutes / 60
	var phase := L.t("GECE")
	if hour >= 6 and hour < 10:
		phase = L.t("SABAH")
	elif hour >= 10 and hour < 17:
		phase = L.t("GÜNDÜZ")
	elif hour >= 17 and hour < 21:
		phase = L.t("AKŞAM")
	return L.t("%s  %02d:%02d  •  Gün %d") % [phase, hour, minutes % 60, int(elapsed / DAY_SECONDS) + 1]

func _update_daylight() -> void:
	day_tint.color = _day_color(elapsed) * (Color(0.78,0.7,0.83) if floor_index==2 else Color.WHITE)
	var darkness := 1.0 - day_tint.color.r
	for i in range(lanterns.size()):
		lanterns[i].energy = 0.08 + darkness * 1.1
		if i == 0:
			lanterns[i].position = player

func _create_lanterns() -> void:
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 128
	texture.height = 128
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1, 0.5)
	for pos in [Vector2.ZERO, Vector2(-190, 125), Vector2(720, -380), Vector2(-780, -430), Vector2(1110, 690), Vector2(-1130, 730)]:
		var light := PointLight2D.new()
		light.texture = texture
		light.texture_scale = 3.0 if lanterns.is_empty() else 2.2
		light.color = Color("ffdcaa")
		light.position = pos
		# A single moving light avoids six full-screen light passes on phones.
		light.enabled = lanterns.is_empty() or not OS.has_feature("mobile")
		add_child(light)
		lanterns.append(light)

func _reset_supplies() -> void:
	fountains.clear()
	chests.clear()
	for pos in [Vector2(-190, 125), Vector2(720, -380), Vector2(-780, -430), Vector2(1110, 690), Vector2(-1130, 730)]:
		fountains.append({"pos": pos, "index": fountains.size()})
	for pos in [Vector2(235, 105), Vector2(-460, -240), Vector2(750, 350), Vector2(-980, 140), Vector2(1290, -700), Vector2(-1320, -790), Vector2(450, -860), Vector2(-700, 860), Vector2(1480, 860)]:
		chests.append({"pos": pos, "opened": false, "offered": false})

func _update_supplies(dt: float) -> void:
	for fountain in fountains:
		if player.distance_to(fountain.pos) < 42 and economy.healing_ready(fountain.index) and hp < max_hp:
			economy.consume_healing(fountain.index)
			hp = minf(max_hp, hp + 35)
			notice = L.t("Şifa pınarı • +35 can • Yeniden dolum için 25 düşman")
			notice_left = 3
			_effect(player, 40, Color("86e4b2"), 0.4)
	for chest in chests:
		if player.distance_to(chest.pos) > 65:
			chest.offered = false
		if not chest.opened and not chest.offered and player.distance_to(chest.pos) < 37:
			_open_chest(chest)
			return

func _open_chest(chest: Dictionary) -> void:
	if mode != "play" or chest.opened:
		return
	chest.offered = true
	if economy.coins < economy.chest_price():
		notice = L.t("Sandık %d altın • Sende %d altın var") % [economy.chest_price(), economy.coins]
		notice_left = 3
		return
	mode = "chest_offer"
	_clear_modal(L.t("SANDIK • %d ALTIN") % economy.chest_price(), L.t("Cüzdan: %d altın\nAçılıştan sonra altın kazancı +%%15.") % economy.coins)
	modal_stack.add_child(_button(L.t("SATIN AL VE AÇ"), _purchase_chest.bind(chest)))
	modal_stack.add_child(_button(L.t("VAZGEÇ"), _resume))

func _purchase_chest(chest: Dictionary) -> void:
	if mode != "chest_offer" or chest.opened or not economy.buy_chest():
		return
	chest.opened = true
	mode = "chest"
	pending_loot = Loot.roll(starting_hero,luck,rng)
	_clear_modal(L.t("SANDIK ÖDÜLÜ"),L.t("Başlangıç karakteri: %s • Şans: %d")%[Roster.HEROES[starting_hero].name,roundi(luck)])
	var icon := TextureRect.new()
	icon.texture = Loot.icon(pending_loot)
	icon.custom_minimum_size = Vector2(64,64)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	modal_stack.add_child(icon)
	_label(modal_stack,L.t(pending_loot.name)+" • "+L.t(Loot.TIERS[pending_loot.tier]),23,Loot.COLORS[pending_loot.tier])
	_label(modal_stack,Loot.description(pending_loot),16,Color("e3d9ba"))
	modal_stack.add_child(_button(L.t("AL VE KUŞAN"),_claim_loot))
	modal_stack.add_child(_button(L.t("BIRAK"),_discard_loot))
	battle_audio.play_event("chest",0.8)

func _draw_supplies() -> void:
	_draw_encounter()
	for corpse in corpses:
		var key := EnemyArt.key(corpse.kind,corpse.variant,floor_index,Vector2.DOWN)
		EnemyArt.paint(self,key,"death",0.8-corpse.life,corpse.pos,48,false,Color(1,1,1,corpse.life/0.8))
	for mark in placed_markers:
		if mark.floor == floor_index: Markers.paint(self,mark.pos,mark.flag,elapsed)
	if not last_death.is_empty() and last_death.floor == floor_index:
		Markers.paint(self,last_death.pos,last_death.flag,elapsed,true)
	for fountain in fountains:
		var p: Vector2 = fountain.pos
		var ready: bool = economy.healing_ready(fountain.index)
		draw_circle(p, 38, Color(0.4, 0.8, 0.65, 0.12) if ready else Color(0.2, 0.3, 0.3, 0.2))
		draw_rect(Rect2(p + Vector2(-20, -8), Vector2(40, 19)), Color("7f9184"))
		draw_rect(Rect2(p + Vector2(-15, -9), Vector2(30, 12)), Color("6fc7b3") if ready else Color("486969"))
		draw_rect(Rect2(p + Vector2(-5, -32), Vector2(10, 22)), Color("a3b9a0"))
		draw_rect(Rect2(p + Vector2(-12, -25), Vector2(24, 7)), Color("c9e8b4") if ready else Color("738478"))
		if not ready:
			var remaining: int = economy.heal_targets[fountain.index] - kills
			draw_string(ThemeDB.fallback_font, p + Vector2(-20, 27), L.t("%d av") % remaining, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("c7d3b3"))
	for chest in chests:
		var p: Vector2 = chest.pos
		draw_rect(Rect2(p + Vector2(-17, 3), Vector2(36, 10)), Color("29382c"))
		draw_rect(Rect2(p + Vector2(-15, -12), Vector2(30, 22)), Color("865d38"))
		draw_rect(Rect2(p + Vector2(-15, -13 if not chest.opened else -26), Vector2(30, 10)), Color("b38b4c"))
		draw_rect(Rect2(p + Vector2(-15, -3), Vector2(30, 3)), Color("e0be75"))
		draw_rect(Rect2(p + Vector2(-3, -6), Vector2(6, 9)), Color("f0d88e"))
		if not chest.opened:
			draw_string(ThemeDB.fallback_font, p + Vector2(-21, 27), L.t("%d altın") % economy.chest_price(), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("e8d6a1"))
			var star := p + Vector2(0, -33 + sin(elapsed * 3) * 3)
			draw_line(star - Vector2(4, 0), star + Vector2(4, 0), Color("ead598"), 2)
			draw_line(star - Vector2(0, 4), star + Vector2(0, 4), Color("ead598"), 2)

func _update_trails(dt: float) -> void:
	for i in range(trails.size() - 1, -1, -1):
		trails[i].life -= dt
		if trails[i].life <= 0:
			trails.remove_at(i)
	last_trail -= dt
	if dash_left > 0 and last_trail <= 0:
		trails.append({"pos": player, "life": 0.23})
		last_trail = 0.035

func _update_coins(dt: float) -> void:
	for i in range(coin_drops.size() - 1, -1, -1):
		var coin: Dictionary = coin_drops[i]
		if player.distance_to(coin.pos) < magnet:
			coin.pos = coin.pos.move_toward(player, 260 * dt)
		if player.distance_to(coin.pos) < 17:
			economy.coins += coin.value
			coin_drops.remove_at(i)

func _complete_floor() -> void:
	if mode != "play" or not boss_defeated or not portal_active or player.distance_to(portal_position)>75:
		return
	for coin in coin_drops:
		economy.coins += coin.value
	coin_drops.clear()
	for gem in gems:
		xp += gem.xp
	gems.clear()
	var book := Scores.new()
	book.path = score_path
	book.read()
	var duration := maxf(0.001, elapsed - floor_start_time)
	if book.add_completion(floor_index + 1, selected_hero, duration) != OK:
		push_warning(L.t("Kat süresi kaydedilemedi."))
	completed_chapters += 1
	_save_progress()
	if floor_index == 2:
		_finish(true)
		return
	mode = "floor_clear"
	_clear_modal(L.t("KAT %d TAMAMLANDI") % (floor_index + 1), L.t("Seviye %d • %.2f saniye\nAltın, EXP ve geliştirmeler sonraki kata taşınır.") % [level, duration])
	if completed_chapters < Roster.HEROES.size():
		_label(modal_stack, L.t("Yeni savaşçı: ") + Roster.HEROES[completed_chapters].name, 17, Color("d8ca98"))
	modal_stack.add_child(_button(L.t("AYNI SAVAŞÇIYLA DEVAM"), _advance_floor))
	modal_stack.add_child(_button(L.t("KARAKTER DEĞİŞTİR"), _choose_floor_hero))

func _choose_floor_hero() -> void:
	_clear_modal(L.t("SONRAKİ KAT • SAVAŞÇI SEÇ"), L.t("Seviyen, altının ve geliştirme bonusların korunur."))
	for i in range(Roster.HEROES.size()):
		if _hero_unlocked(i):
			modal_stack.add_child(_button(Roster.HEROES[i].name, _continue_as.bind(i)))

func _continue_as(index: int) -> void:
	if mode != "floor_clear" or not _hero_unlocked(index):
		return
	var old: Dictionary = Roster.HEROES[selected_hero]
	var next: Dictionary = Roster.HEROES[index]
	var health_ratio := hp / max_hp
	max_hp = next.hp + (max_hp - old.hp)
	hp = max_hp * health_ratio
	damage = next.damage * damage / old.damage
	speed = next.speed * speed / old.speed
	attack_period = next.period * attack_period / old.period
	reach = next.reach + (reach - old.reach)
	selected_hero = index
	_save_progress()
	_advance_floor()

func _advance_floor() -> void:
	pet_position = Vector2.ZERO
	shield_time = 0
	shield_cooldown = 0
	if mode != "floor_clear" or floor_index >= 2:
		return
	_reset_encounter()
	floor_index += 1
	chapter = floor_index + 1
	economy.floor_index = floor_index
	floor_start_time = elapsed
	boss_spawned = false
	player = Vector2.ZERO
	camera.position = player
	wave = 1
	wave_time = 0
	spawn_cd = 1
	immunity = 1.5
	dash_left = 0
	enemies.clear()
	shots.clear()
	hero_shots.clear()
	effects.clear()
	trails.clear()
	_reset_supplies()
	_resume()
	_wave_banner()
	battle_audio.start_floor(floor_index)

func _update_hero_shots(dt: float) -> void:
	for i in range(hero_shots.size() - 1, -1, -1):
		var arrow: Dictionary = hero_shots[i]
		var old: Vector2 = arrow.pos
		arrow.pos += arrow.velocity * dt
		arrow.life -= dt
		var hit := false
		for enemy in enemies:
			if enemy.emerge > 0:
				continue
			var closest := Geometry2D.get_closest_point_to_segment(enemy.pos, old, arrow.pos)
			if closest.distance_to(enemy.pos) <= enemy.radius + 4:
				enemy.hp -= arrow.damage
				enemy.flash = 0.16
				hit = true
				break
		if hit or arrow.life <= 0:
			hero_shots.remove_at(i)
	_reap_enemies()

func _draw_enemy(enemy: Dictionary) -> void:
	var kind: int=enemy.kind
	var key := EnemyArt.key(kind,enemy.variant,floor_index,player-enemy.pos)
	var state := "attack" if enemy.attack_visual>0 else "run"
	var time: float=enemy.anim
	if enemy.emerge>0:
		if kind==6:
			state="emerge"
			time=(0.9-enemy.emerge)*1.6
		else:
			draw_arc(enemy.pos,enemy.radius+5,0,TAU,20,Color("a488ad"),2)
			return
	var tint := Color.WHITE
	if kind==1: tint=[Color.WHITE,Color("b49bbf"),Color("91b3a8")][enemy.variant%3]
	var height: float=[32,44,66 if enemy.variant==2 else 48,95,47,43,40,78][kind]
	EnemyArt.paint(self,key,state,time,enemy.pos,height,(player.x<enemy.pos.x) if kind!=3 else false,tint)
	if (kind==2 and enemy.variant==2) or kind==7:
		draw_rect(Rect2(enemy.pos+Vector2(-22,-height-7),Vector2(44,3)),Color("302536"))
		draw_rect(Rect2(enemy.pos+Vector2(-22,-height-7),Vector2(44*enemy.hp/enemy.max_hp,3)),Color("c27491"))

func _place_marker() -> void:
	if mode != "play" or placed_markers.size()>=2: return
	placed_markers.append({"pos":player,"floor":floor_index,"flag":selected_flag})
	notice = L.t("Bayrak ve kedi bırakıldı. Kalan hak: %d")%(2-placed_markers.size())
	notice_left = 3

func _claim_loot() -> void:
	if mode!="chest" or pending_loot.is_empty(): return
	var item := pending_loot.duplicate(true)
	pending_loot.clear()
	inventory.append(item)
	if item.get("defense",false): defenses.equip(item,max_hp)
	if item.get("grants_shield",false): defenses.equip(Loot.Defense.item(0,0,3),max_hp)
	damage *= 1+item.damage
	speed = maxf(60,speed*(1+item.speed))
	attack_period = maxf(0.18,attack_period/(1+item.rate))
	max_hp += item.health
	hp = minf(max_hp,hp+item.health)
	reach += item.reach
	luck = minf(60,luck+item.luck)
	_resume()

func _discard_loot() -> void:
	if mode!="chest": return
	pending_loot.clear()
	_resume()

func _show_inventory() -> void:
	if mode!="play": return
	mode = "inventory"
	_clear_modal(L.t("ÇANTA"),L.t("Başlangıç karakteri: %s • Şans: %d")%[Roster.HEROES[starting_hero].name,roundi(luck)])
	var rates := Loot.odds(luck)
	_label(modal_stack,"Regular %.1f%% • Epic %.1f%% • Legend %.1f%% • %s %.1f%%"%[rates[0],rates[1],rates[2],L.t("Destansı"),rates[3]],14,Color("d8c692"))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(490,180)
	modal_stack.add_child(scroll)
	var list := VBoxContainer.new()
	scroll.add_child(list)
	for family in defenses.modules:
		var module: Dictionary=defenses.modules[family]
		_label(list,L.t("AKTİF: %s • Yığın %d/3")%[module.item.name,module.stacks],14,Color("8fe2c7"))
	if inventory.is_empty(): _label(list,L.t("Henüz item yok. Sandıkları keşfet."),17,Color.WHITE)
	for item in inventory:
		_label(list,L.t(item.name)+" • "+Loot.description(item),14,Loot.COLORS[item.tier])
	modal_stack.add_child(_button(L.t("DEVAM ET"),_resume))

func _reset_encounter() -> void:
	ritual_ready=false
	boss_active=false
	boss_defeated=false
	boss_spawned=false
	boss_elapsed=0
	horde_active=false
	horde_cd=0
	portal_active=false
	scaling_cd=0
	corpses.clear()
	queued_summons.clear()

func _remote_point(origin: Vector2) -> Vector2:
	for i in range(40):
		var point := Vector2(rng.randf_range(-1850,1850),rng.randf_range(-1050,1050))
		if point.distance_to(origin)>650: return point
	return Vector2(-1600 if origin.x>0 else 1600,800)

func _update_encounter(dt: float) -> void:
	for i in range(corpses.size()-1,-1,-1):
		corpses[i].life-=dt
		if corpses[i].life<=0: corpses.remove_at(i)
	if wave>=10 and not ritual_ready:
		ritual_ready=true
		ritual_position=_remote_point(player)
		notice=L.t("Boss sunağı açıldı. Küçük haritadaki mor halkaya git.")
		notice_left=8
	if boss_active:
		boss_elapsed+=dt
		if boss_elapsed>=240 and not horde_active:
			horde_active=true
			notice=L.t("Dört dakika doldu! Demon ve ruh akını başladı.")
			notice_left=6
	if horde_active and (boss_active or portal_active):
		horde_cd-=dt
		if horde_cd<=0:
			horde_cd=(3.5 if floor_index==2 else 7.0)*(0.6 if _is_night() else 1.0)
			for i in range(5 if floor_index==2 else 3):
				_spawn(4 if i%2==0 else 5)
			if floor_index==2 and boss_spawned and rng.randf()<0.35: _spawn(7)
	scaling_cd-=dt
	if scaling_cd<=0:
		scaling_cd=1
		for enemy in enemies:
			var stats := _enemy_stats(enemy.kind,enemy.variant)
			var ratio: float=clampf(enemy.hp/enemy.max_hp,0,1)
			enemy.max_hp=stats.hp
			enemy.hp=stats.hp*ratio
			for key in ["damage","speed","attack_rate"]: enemy[key]=stats[key]

func _interact_encounter() -> void:
	if mode!="play": return
	if portal_active and player.distance_to(portal_position)<75:
		_complete_floor()
	elif ritual_ready and not boss_spawned and player.distance_to(ritual_position)<90:
		boss_spawned=true
		boss_active=true
		boss_elapsed=0
		_spawn(3,ritual_position+Vector2(95,0))
		if floor_index==2:
			horde_active=true
			horde_cd=0
			_spawn(7,ritual_position+Vector2(-100,0))
		notice=L.t("AKIN BAŞLADI") if floor_index==2 else L.t("Boss çağrıldı. Akına kadar 4 dakika!")
		notice_left=5

func _boss_killed() -> void:
	if not boss_active: return
	boss_active=false
	boss_defeated=true
	portal_active=true
	portal_position=_remote_point(player)
	notice=L.t("Boss yenildi! Yeşil portalı bul. Hazır olana kadar savaşabilirsin.")
	notice_left=8

func _draw_encounter() -> void:
	if ritual_ready and not boss_defeated:
		var color := Color("b079d9")
		draw_circle(ritual_position,43,Color(0.18,0.06,0.25,0.7))
		draw_arc(ritual_position,43,elapsed,elapsed+TAU,32,color,3)
		for i in range(6):
			var point := ritual_position+Vector2.from_angle(i*TAU/6)*43
			draw_rect(Rect2(point-Vector2(4,4),Vector2(8,8)),color)
	if portal_active:
		draw_circle(portal_position,40,Color(0.05,0.25,0.23,0.8))
		for i in range(3):
			draw_arc(portal_position,25+i*9,elapsed*(i+1),elapsed*(i+1)+TAU*0.85,32,Color("77e8ba"),3)
		draw_line(portal_position+Vector2(-40,15),portal_position+Vector2(-40,-50),Color("879a91"),7)
		draw_line(portal_position+Vector2(40,15),portal_position+Vector2(40,-50),Color("879a91"),7)
		draw_line(portal_position+Vector2(-40,-50),portal_position+Vector2(40,-50),Color("aab6a2"),7)


