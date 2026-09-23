extends Control
const L = preload("res://scripts/localization.gd")
## Main menu, persistent settings and explicit campaign entry.
const Art = preload("res://scripts/pixel_art.gd")
const StoneButton = preload("res://scripts/stone_button.gd")
const Roster = preload("res://scripts/roster.gd")
const Items = preload("res://scripts/item_catalog.gd")
const Scoreboard = preload("res://scripts/scoreboard.gd")
const AudioLibrary = preload("res://scripts/audio_library.gd")
const WorldAtlas = preload("res://scripts/world_atlas.gd")
const Markers = preload("res://scripts/trail_markers.gd")
const Loot = preload("res://scripts/chest_loot.gd")
var selected_flag := "TR"
const DESIGN := Vector2(960, 540)
var audio_enabled := true
var settings_path := "user://bozkir_settings.cfg"
var progress_path := "user://bozkir_progress.cfg"
var music_volume := 0.35
var effect_volume := 0.55
var muted := false
var reduced_motion := false
var completed_chapters := 0
var selected_hero := 0
var preview_hero := 0
var clock := 0.0
var fit := 1.0
var origin := Vector2.ZERO
var content: Control
var play_button: Button
var sound_button: Button
var cards: Array[Button] = []
var description: Label
var music: AudioStreamPlayer
var click_sound: AudioStreamPlayer
var veil: ColorRect
var popup: PanelContainer
var stack: VBoxContainer
var popup_kind := ""
var music_slider: HSlider
var effects_slider: HSlider
var popup_heading := ""
var score_path := "user://bozkir_scores.cfg"
var scores := Scoreboard.new()
var info_name: Label
var rating_labels: Array[Label] = []
var rating_bars: Array[ProgressBar] = []
var ultimate_name: Label
var ultimate_summary: Label
var ultimate_gate: Label
var best_label: Label
var track_index := 0
var language_picker: OptionButton
var entering_game := false

func _ready() -> void:
	_load_settings()
	_load_progress()
	scores.path = score_path
	scores.read()
	_setup_audio()
	content = Control.new()
	content.size = DESIGN
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(content)
	_build_menu()
	_build_popup()
	resized.connect(_layout)
	_layout()
	_refresh_cards()

func _layout() -> void:
	var safe := preload("res://scripts/phone_layout.gd").safe_rect(get_viewport())
	fit = minf(safe.size.x / DESIGN.x, safe.size.y / DESIGN.y)
	origin = (safe.position+(safe.size - DESIGN * fit) / 2).floor()
	content.position = origin
	content.scale = Vector2.ONE * fit
	queue_redraw()

func _build_menu() -> void:
	play_button = _stone(L.t("PLAY"), Rect2(350, 258, 260, 60), _play_preview, 4)
	for i in range(Roster.HEROES.size()):
		var card := _stone(Roster.HEROES[i].name, Rect2(220 + i * 106, 337, 96, 103), _preview_character.bind(i), 1)
		card.hero_index = i
		cards.append(card)
	description = Label.new()
	description.position = Vector2(210, 441)
	description.size = Vector2(540, 20)
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.add_theme_font_size_override("font_size", 13)
	description.add_theme_color_override("font_color", Color("ded8ac"))
	description.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(description)
	_build_character_info()
	_stone(L.t("OGELER"), Rect2(66, 195, 139, 39), _show_items, 2)
	_stone(L.t("SKORLAR"), Rect2(753, 195, 141, 39), _show_scores, 2)
	var item_note := _info_label(L.t("Karaktere özel itemler"), Vector2(66, 236), Vector2(139, 17), 12)
	item_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	best_label = _info_label("", Vector2(752, 236), Vector2(144, 17), 12)
	best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_refresh_best()
	_stone(L.t("DÜŞMANLAR"),Rect2(753,91,141,32),_show_enemies,1)
	_stone(L.t("ANIMASYON"), Rect2(753, 136, 141, 39), _show_animations, 1)
	_stone(L.t("BAYRAK"), Rect2(66,91,139,32), _show_flags, 2)
	_stone(L.t("DUNYA"), Rect2(66, 136, 139, 39), _show_world, 2)
	_stone(">", Rect2(185, 482, 28, 29), _next_track, 2)
	_stone(L.t("HELP"), Rect2(242, 474, 142, 39), _show_help, 2)
	_stone(L.t("SETTINGS"), Rect2(396, 474, 168, 39), _show_settings, 2)
	_stone(L.t("QUIT"), Rect2(576, 474, 142, 39), _show_quit, 2)
	sound_button = _stone(L.t("SES"), Rect2(812, 42, 77, 32), _toggle_mute, 2)
	_refresh_sound_button()

func _stone(caption: String, rect: Rect2, action: Callable, pixel := 2, parent: Node = null) -> Button:
	var button := StoneButton.new()
	button.caption = caption
	button.font_pixel = pixel
	button.position = rect.position
	button.size = rect.size
	button.custom_minimum_size = rect.size
	button.animated = not reduced_motion
	button.button_down.connect(_click)
	button.pressed.connect(action)
	(parent if parent != null else content).add_child(button)
	return button

func _build_popup() -> void:
	veil = ColorRect.new()
	veil.color = Color(0.1, 0.14, 0.1, 0.83)
	veil.size = DESIGN
	content.add_child(veil)
	var center := CenterContainer.new()
	center.size = DESIGN
	veil.add_child(center)
	popup = PanelContainer.new()
	popup.custom_minimum_size.x = 520
	var stone := StyleBoxFlat.new()
	stone.bg_color = Color("7d8161")
	stone.border_color = Color("c6bc8b")
	stone.set_border_width_all(4)
	stone.shadow_color = Color("303b2e")
	stone.shadow_offset = Vector2(6, 7)
	stone.shadow_size = 2
	stone.content_margin_left = 28
	stone.content_margin_right = 28
	stone.content_margin_top = 23
	stone.content_margin_bottom = 22
	popup.add_theme_stylebox_override("panel", stone)
	center.add_child(popup)
	stack = VBoxContainer.new()
	stack.add_theme_constant_override("separation", 13)
	popup.add_child(stack)
	veil.hide()

func _open_popup(kind: String, heading: String) -> void:
	popup_kind = kind
	popup_heading = heading
	popup.custom_minimum_size.x = 520
	for node in stack.get_children():
		stack.remove_child(node)
		node.queue_free()
	veil.show()
	var title := Label.new()
	title.text = heading
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 29)
	title.add_theme_color_override("font_color", Color("eee5ba"))
	stack.add_child(title)
	# Modal dialogs retain keyboard focus; the obscured menu cannot be activated.
	for button in _menu_buttons():
		button.focus_mode = Control.FOCUS_NONE

func _body(value: String) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.x = 450
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color("eee6c3"))
	stack.add_child(label)
	return label

func _popup_button(caption: String, action: Callable) -> Button:
	var button := _stone(caption, Rect2(0, 0, 450, 42), action, 2, stack)
	return button

func _close_popup() -> void:
	if popup_kind == "settings":
		_save_settings()
	veil.hide()
	popup_kind = ""
	for button in _menu_buttons():
		button.focus_mode = Control.FOCUS_ALL
	play_button.grab_focus()

func _menu_buttons() -> Array[Button]:
	var result: Array[Button] = []
	for node in content.get_children():
		if node is Button:
			result.append(node)
	return result

func _play_preview() -> void:
	if entering_game: return
	entering_game = true
	_save_settings()
	var game = load("res://scenes/main.tscn").instantiate()
	game.selected_flag = selected_flag
	game.launch_from_menu = true
	game.launch_hero = selected_hero
	game.audio_enabled = audio_enabled
	game.profile_path = progress_path
	game.score_path = score_path
	music.stop()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	queue_free()

func _show_help() -> void:
	_open_popup("help", L.t("HELP  /  NASIL OYNANIR?"))
	_body(L.t("Hareket: WASD / yön tuşları veya sol joystick.\nAtılma: Boşluk veya ATIL. Bekleme: 3 saniye.\n\nHer katta 10. dalgada sunağı bul, bossu çağır ve yen. Açılan portaldan geç. Düşmanlardan altın ve EXP topla. Sandıklar altınla, şifa alanları öldürme sayısıyla açılır.\n\nOYNA ile seçili karakterinle ilk kata gir."))
	_popup_button(L.t("GERI"), _close_popup).grab_focus()

func _show_settings() -> void:
	_open_popup("settings", L.t("SETTINGS  /  AYARLAR"))
	var language_label := _body(L.t("Dil / Language"))
	language_label.add_theme_font_size_override("font_size",16)
	language_picker = OptionButton.new()
	language_picker.add_item("Türkçe",0)
	language_picker.add_item("English",1)
	language_picker.select(1 if L.locale == "en" else 0)
	language_picker.custom_minimum_size.y = 34
	language_picker.item_selected.connect(_change_language)
	stack.add_child(language_picker)
	music_slider = _slider(L.t("Müzik • 8 parça"), music_volume, _music_changed)
	effects_slider = _slider(L.t("Ses efektleri"), effect_volume, _effects_changed)
	var motion := CheckButton.new()
	motion.text = L.t("Menü hareketlerini azalt")
	motion.button_pressed = reduced_motion
	motion.add_theme_font_size_override("font_size", 17)
	motion.add_theme_color_override("font_color", Color("eee6c3"))
	motion.toggled.connect(_motion_changed)
	stack.add_child(motion)
	_body(L.t("Ayarlar bu cihazda saklanır.")).add_theme_font_size_override("font_size", 14)
	_popup_button(L.t("KAYDET VE DON"), _close_popup)
	music_slider.grab_focus()

func _slider(caption: String, initial: float, changed: Callable) -> HSlider:
	var row := HBoxContainer.new()
	stack.add_child(row)
	var label := Label.new()
	label.text = caption
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_color_override("font_color", Color("eee6c3"))
	label.add_theme_font_size_override("font_size", 17)
	row.add_child(label)
	var percentage := Label.new()
	percentage.text = "%d%%" % roundi(initial * 100)
	percentage.add_theme_color_override("font_color", Color("eee6c3"))
	row.add_child(percentage)
	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 1
	slider.value = initial * 100
	slider.custom_minimum_size.y = 30
	var track := StyleBoxFlat.new()
	track.bg_color = Color("434d38")
	track.content_margin_top = 5
	track.content_margin_bottom = 5
	slider.add_theme_stylebox_override("slider", track)
	var fill := track.duplicate()
	fill.bg_color = Color("cbbd87")
	slider.add_theme_stylebox_override("grabber_area", fill)
	slider.add_theme_stylebox_override("grabber_area_highlight", fill)
	slider.value_changed.connect(func(value: float): percentage.text = "%d%%" % roundi(value); changed.call(value / 100.0))
	stack.add_child(slider)
	return slider

func _show_quit() -> void:
	_open_popup("quit", L.t("YOLCULUGA ARA VER"))
	_body(L.t("Oyundan çıkmak istiyor musun?"))
	_popup_button(L.t("VAZGEC"), _close_popup).grab_focus()
	_popup_button(L.t("CIKIS"), func(): _save_settings(); get_tree().quit())

func _preview_character(index: int) -> void:
	preview_hero = index
	if index <= completed_chapters:
		selected_hero = index
	_refresh_cards()

func _refresh_cards() -> void:
	for i in range(cards.size()):
		cards[i].locked = i > completed_chapters
		cards[i].selected = i == selected_hero
		cards[i].queue_redraw()
	var hero: Dictionary = Roster.HEROES[preview_hero]
	if preview_hero > completed_chapters:
		description.text = L.t("%s • Kilitli — Bölüm %d zaferinde açılır") % [hero.name, preview_hero]
	else:
		description.text = L.t("%s • %s • Özellikleri incelemek için DETAYLAR") % [hero.name, L.t(hero.style)]
	info_name.text = hero.name.to_upper()
	var keys := ["damage", "speed", "attack_speed"]
	var names := [L.t("HASAR"), L.t("HIZ"), L.t("SALDIRI HIZI")]
	for i in range(3):
		rating_labels[i].text = "%s  %d/100" % [names[i], hero.ratings[keys[i]]]
		rating_bars[i].value = hero.ratings[keys[i]]
	ultimate_name.text = L.t(hero.ultimate)
	ultimate_summary.text = [L.t("Gökten yıldırım düşürür."), L.t("Mermileri emer,\nulti gücü toplar."), L.t("Yerden çıkan\noklarla saldırır."), L.t("Art arda mızrak\nvuruşları yapar."), L.t("Seri ve ağır\ndarbeler yağdırır.")][preview_hero]
	ultimate_gate.text = L.t(hero.ultimate_gate)
	queue_redraw()

func _info_label(value: String, pos: Vector2, dimensions: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.text = value
	label.position = pos
	label.size = dimensions
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("e4dfb4"))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(label)
	return label

func _build_character_info() -> void:
	info_name = _info_label("ALP", Vector2(78, 270), Vector2(115, 25), 22)
	_info_label(L.t("BAŞLANGIÇ / 100"), Vector2(78, 297), Vector2(118, 20), 10)
	for i in range(3):
		var label := _info_label("", Vector2(78, 325 + i * 41), Vector2(118, 20), 9 if L.locale == "en" and i == 2 else 11)
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
		rating_labels.append(label)
		var bar := ProgressBar.new()
		bar.position = Vector2(78, 347 + i * 41)
		bar.size = Vector2(112, 7)
		bar.show_percentage = false
		bar.add_theme_font_size_override("font_size", 1)
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var back := StyleBoxFlat.new()
		back.bg_color = Color("394630")
		var fill := StyleBoxFlat.new()
		fill.bg_color = Color("cfc08a")
		bar.add_theme_stylebox_override("background", back)
		bar.add_theme_stylebox_override("fill", fill)
		content.add_child(bar)
		bar.size = Vector2(112, 7)
		rating_bars.append(bar)
	_info_label(L.t("ULTİMATE"), Vector2(766, 272), Vector2(114, 20), 12)
	ultimate_name = _info_label("", Vector2(766, 294), Vector2(115, 40), 17)
	ultimate_summary = _info_label("", Vector2(766, 338), Vector2(115, 53), 13)
	ultimate_gate = _info_label("", Vector2(766, 391), Vector2(115, 32), 10)
	_stone(L.t("DETAYLAR"), Rect2(766, 430, 114, 28), _show_hero, 1)

func _show_hero() -> void:
	var hero: Dictionary = Roster.HEROES[preview_hero]
	_open_popup("hero", "%s  /  %s" % [hero.name.to_upper(), L.t(hero.style)])
	_body(L.t("Hasar %d/100     Hız %d/100     Saldırı hızı %d/100") % [hero.ratings.damage, hero.ratings.speed, hero.ratings.attack_speed]).add_theme_font_size_override("font_size", 16)
	_body(L.t("GÜÇLENME\n") + L.t(hero.passive))
	_body(L.t("ULTİMATE • ") + L.t(hero.ultimate) + "\n" + L.t(hero.ultimate_text))
	_body(L.t(hero.ultimate_gate)).add_theme_font_size_override("font_size", 14)
	if hero.legendary_level > 0:
		_body(L.t("11. seviyeden itibaren rastgele efsanevi yetenekler.")).add_theme_font_size_override("font_size", 14)
	_body(L.t("Temel saldırılar hazır. Özel ultiler geliştirme aşamasında.")).add_theme_font_size_override("font_size", 12)
	_popup_button(L.t("GERI"), _close_popup).grab_focus()

func _show_items() -> void:
	_open_popup("items",L.t("SANDIK İTEMLERİ")+" • "+Roster.HEROES[preview_hero].name)
	popup.custom_minimum_size.x = 800
	_body(L.t("Sandıklar koşuya başladığın karaktere göre rastgele ödül verir.")).add_theme_font_size_override("font_size",14)
	_body(L.t("500 savunma öğesi • Karakter başına 100 • 10 çalışan mekanizma")).add_theme_font_size_override("font_size",14)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(720,235)
	stack.add_child(scroll)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation",20)
	grid.add_theme_constant_override("v_separation",12)
	scroll.add_child(grid)
	var items: Array = []
	for tier in range(4): items.append_array(Loot.Defense.pool(preview_hero,tier))
	for tier in range(4): items.append(Loot.item(preview_hero,tier))
	items.append(Loot.charm(0))
	items.append(Loot.charm(1))
	for item in items:
		var row := HBoxContainer.new()
		grid.add_child(row)
		var icon := TextureRect.new()
		icon.texture = Loot.icon(item)
		icon.custom_minimum_size = Vector2(38,38)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(icon)
		var column := VBoxContainer.new()
		row.add_child(column)
		var title := _small_label(column,L.t(item.name)+" • "+L.t(Loot.TIERS[item.tier]),15,Loot.COLORS[item.tier])
		title.custom_minimum_size.x=287
		title.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		var label := _small_label(column,Loot.description(item),12,Color("e3d9ba"))
		label.custom_minimum_size.x = 287
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body(L.t("Temel oranlar: Regular %70 • Epic %22 • Legend %7 • Destansı %1. Şans nadirliği artırır; garanti vermez.")).add_theme_font_size_override("font_size",14)
	_popup_button(L.t("GERI"),_close_popup)

func _small_label(parent: Node, value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func _refresh_best() -> void:
	best_label.text = L.t("Henüz süre kaydı yok") if scores.records.is_empty() else L.t("Rekor: %.2f sn") % scores.records[0].seconds

func _show_scores() -> void:
	scores.read()
	_refresh_best()
	_open_popup("scores", L.t("SKOR TABLOSU"))
	_body(L.t("Bu cihazdaki bölüm rekorları • En kısa süre önce")).add_theme_font_size_override("font_size", 14)
	if scores.records.is_empty():
		_body(L.t("Henüz tamamlanmış bölüm kaydı yok.\n\nBoss yenilip portala girildiğinde karakter, kat ve süre kaydedilir."))
	else:
		var scroll := ScrollContainer.new()
		scroll.custom_minimum_size = Vector2(450, 220)
		stack.add_child(scroll)
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.add_theme_constant_override("separation", 12)
		scroll.add_child(column)
		for record in scores.records:
			var line := L.t("Bölüm %d   •   %s   •   %.3f sn") % [record.chapter, Roster.HEROES[record.hero].name, record.seconds]
			_small_label(column, line, 17, Color("eee6c3"))
	_body(L.t("Yerel kayıt • Duraklama ve seçim ekranlarında geçen süre sayılmaz.")).add_theme_font_size_override("font_size", 12)
	_popup_button(L.t("GERI"), _close_popup).grab_focus()

func _setup_audio() -> void:
	music = AudioStreamPlayer.new()
	music.name = "MenuMusic"
	add_child(music)
	music.finished.connect(_next_track)
	click_sound = AudioStreamPlayer.new()
	click_sound.name = "StoneClick"
	click_sound.stream = load(AudioLibrary.SOUNDS.ui[0])
	click_sound.max_polyphony = 4
	add_child(click_sound)
	_apply_audio()
	_play_track(0)

func _play_track(index: int) -> void:
	track_index = posmod(index, AudioLibrary.MENU_TRACKS.size())
	var stream: AudioStreamMP3 = load(AudioLibrary.MENU_TRACKS[track_index]).duplicate()
	stream.loop = false
	music.stream = stream
	if audio_enabled:
		music.play()
	queue_redraw()

func _next_track() -> void:
	_play_track(track_index + 1)

func _show_world() -> void:
	_open_popup("world", L.t("ÜÇ KAT • TEK YOLCULUK"))
	popup.custom_minimum_size.x = 856
	var atlas := WorldAtlas.new()
	atlas.animated = not reduced_motion
	stack.add_child(atlas)
	_body(L.t("Sandık: 20 → 40 → 80 → 160 altın • Her sandık: altın kazancı +%15\nŞifa açılışları: 15 / 40 / 80 / 130 / 200 öldürme • Tekrar dolum: +25 öldürme")).add_theme_font_size_override("font_size", 12)
	_popup_button(L.t("GERI"), _close_popup).grab_focus()

func _make_click() -> AudioStreamWAV:
	var sample_rate := 22050
	var count := int(sample_rate * 0.065)
	var bytes := PackedByteArray()
	bytes.resize(count * 2)
	var random := RandomNumberGenerator.new()
	random.seed = 427
	for i in range(count):
		var t := float(i) / sample_rate
		var envelope := exp(-t * 85.0) * minf(t * 4000, 1)
		var sample := (sin(TAU * 270 * t) * 0.55 + sin(TAU * 1340 * t) * 0.16 + random.randf_range(-1, 1) * 0.25) * envelope
		bytes.encode_s16(i * 2, int(clampf(sample, -1, 1) * 25000))
	var sound := AudioStreamWAV.new()
	sound.format = AudioStreamWAV.FORMAT_16_BITS
	sound.mix_rate = sample_rate
	sound.data = bytes
	return sound

func _click() -> void:
	if audio_enabled and effect_volume > 0:
		click_sound.play()

func _music_changed(value: float) -> void:
	music_volume = value
	muted = value == 0
	_apply_audio()
	_refresh_sound_button()

func _effects_changed(value: float) -> void:
	effect_volume = value
	_apply_audio()

func _motion_changed(value: bool) -> void:
	reduced_motion = value
	for button in _menu_buttons():
		button.animated = not value

func _toggle_mute() -> void:
	muted = not muted
	if not muted and music_volume <= 0:
		music_volume = 0.35
	_apply_audio()
	_refresh_sound_button()
	_save_settings()

func _refresh_sound_button() -> void:
	sound_button.caption = L.t("SESSIZ") if muted or music_volume == 0 else L.t("SES")
	sound_button.font_pixel = 1 if muted or music_volume == 0 else 2
	sound_button.queue_redraw()

func _apply_audio() -> void:
	music.volume_db = -80 if muted or music_volume <= 0 else linear_to_db(music_volume)
	click_sound.volume_db = -80 if effect_volume <= 0 else linear_to_db(effect_volume)

func _load_settings() -> void:
	L.set_locale("tr")
	if settings_path.is_empty():
		return
	var config := ConfigFile.new()
	if config.load(settings_path) != OK:
		return
	selected_flag = Markers.valid_flag(str(config.get_value("cosmetic","flag","TR")))
	L.set_locale(str(config.get_value("interface", "language", "tr")))
	music_volume = _valid_volume(config.get_value("audio", "music", 0.35), 0.35)
	effect_volume = _valid_volume(config.get_value("audio", "effects", 0.55), 0.55)
	muted = config.get_value("audio", "muted", false) == true
	reduced_motion = config.get_value("visual", "reduced_motion", false) == true

func _valid_volume(value: Variant, fallback: float) -> float:
	if (value is float or value is int) and is_finite(float(value)):
		return clampf(float(value), 0, 1)
	return fallback

func _save_settings() -> void:
	if settings_path.is_empty():
		return
	var config := ConfigFile.new()
	config.set_value("cosmetic","flag",selected_flag)
	config.set_value("interface", "language", L.locale)
	config.set_value("audio", "music", music_volume)
	config.set_value("audio", "effects", effect_volume)
	config.set_value("audio", "muted", muted)
	config.set_value("visual", "reduced_motion", reduced_motion)
	if config.save(settings_path) != OK:
		push_warning("Menü ayarları kaydedilemedi.")

func _load_progress() -> void:
	if progress_path.is_empty():
		return
	var config := ConfigFile.new()
	if config.load(progress_path) != OK:
		return
	var completed: Variant = config.get_value("progress", "completed_chapters", 0)
	completed_chapters = clampi(completed, 0, 999) if completed is int else 0
	var hero: Variant = config.get_value("progress", "selected_hero", 0)
	selected_hero = clampi(hero, 0, mini(completed_chapters, 4)) if hero is int else 0
	preview_hero = selected_hero

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE and veil.visible:
		_close_popup()
		get_viewport().set_input_as_handled()

func _process(dt: float) -> void:
	if not reduced_motion:
		clock += dt
		queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("343e30"))
	draw_set_transform(origin, 0, Vector2.ONE * fit)
	draw_rect(Rect2(Vector2.ZERO, DESIGN), Color("73795b"))
	# Broad masonry courses and deterministic speckling, all on an integer grid.
	for row in range(9):
		var y := row * 66
		draw_rect(Rect2(46, y + 3, 868, 2), Color("6c7356"))
		for column in range(7):
			var x := 50 + column * 146 + (66 if row % 2 else 0)
			if x < 910:
				draw_rect(Rect2(x, y + 7, 2, 54), Color("6b7256"))
	for i in range(180):
		var p := Vector2(53 + (i * 167) % 850, 18 + (i * 73) % 510)
		draw_rect(Rect2(p, Vector2(3 + i % 3, 2)), Color("858965") if i % 3 else Color("636f50"))
	# Recessed central stone field keeps the silhouette and lettering clear.
	draw_rect(Rect2(187, 242, 586, 278), Color("5c674e"))
	draw_rect(Rect2(191, 246, 578, 270), Color("646e52"))
	_draw_border()
	for x in [66, 752]:
		draw_rect(Rect2(x + 3, 262, 144, 202), Color("35422f"))
		draw_rect(Rect2(x, 258, 144, 205), Color("a9a77c"))
		draw_rect(Rect2(x + 3, 261, 138, 199), Color("515f44"))
		draw_rect(Rect2(x + 7, 265, 130, 191), Color("626e51"))
	_draw_title()
	_draw_vine(Vector2(198, 10), 187, false)
	_draw_vine(Vector2(754, 8), 160, true)
	_draw_vine(Vector2(51, 28), 164, true)
	_draw_vine(Vector2(904, 365), 125, false)
	_draw_fire(Vector2(480, 62), 1)
	Art.centered(self, L.t("SAVASCINI SEC"), 480, 323, 1, Color("c8c394"), 2)
	var track_name: String = AudioLibrary.MENU_TRACKS[track_index].get_file().get_basename()
	Art.lettering(self, track_name, Vector2(68, 481), 1 if track_name.length() > 8 else 2, Color("c7c391"))
	Art.lettering(self, L.t("%d/8 MENU MUZIGI") % (track_index + 1), Vector2(68, 502), 1, Color("a7b084"))
	Art.lettering(self, L.t("ANA MENU"), Vector2(800, 490), 1, Color("b9bd8e"))
	Art.lettering(self, "V0.3", Vector2(836, 505), 1, Color("a6b181"))
	for i in range(4):
		var phase := fposmod(clock * (9 + i % 3) + i * 37, 100)
		var side := 193 if i < 2 else 747
		var p := Vector2(side + sin(i * 8 + clock * 0.5) * 18, 300 - phase)
		draw_rect(Rect2(p.floor(), Vector2(2, 2)), Color("c8a66a") if i % 2 else Color("a8ac72"))
	draw_set_transform(Vector2.ZERO)

func _draw_title() -> void:
	draw_rect(Rect2(221, 80, 526, 154), Color("3c4434"))
	draw_rect(Rect2(214, 72, 530, 153), Color("d1c796"))
	draw_rect(Rect2(219, 77, 520, 142), Color("424b38"))
	draw_rect(Rect2(226, 84, 506, 128), Color("929574"))
	draw_rect(Rect2(232, 89, 494, 4), Color("aba982"))
	draw_rect(Rect2(235, 204, 482, 3), Color("6d7557"))
	draw_rect(Rect2(270, 72, 12, 5), Color("626e50"))
	draw_rect(Rect2(671, 213, 13, 12), Color("747d5e"))
	Art.centered(self, "BOZKIR", 483, 105, 10, Color("c3bc8b"))
	Art.centered(self, "BOZKIR", 479, 101, 10, Color("3e4734"))
	draw_rect(Rect2(332, 185, 64, 2), Color("575f45"))
	draw_rect(Rect2(564, 185, 64, 2), Color("575f45"))
	Art.centered(self, L.t("SON ALP"), 480, 178, 3, Color("424d37"), 2)
	Art.centered(self, L.t("UNUTULMUS OBA"), 480, 237, 1, Color("d0cd9d"), 3)

func _draw_border() -> void:
	draw_rect(Rect2(0, 0, 960, 7), Color("d0c58e"))
	draw_rect(Rect2(0, 7, 960, 4), Color("3a4531"))
	draw_rect(Rect2(0, 531, 960, 9), Color("c4bc87"))
	draw_rect(Rect2(0, 527, 960, 4), Color("3a4531"))
	for x in [9, 923]:
		draw_rect(Rect2(x, 0, 28, 540), Color("a7a779"))
		draw_rect(Rect2(x - 5, 0, 4, 540), Color("d4ca94"))
		draw_rect(Rect2(x + 29, 0, 5, 540), Color("3e4933"))
		for row in range(12):
			var y := row * 45 + 17
			draw_rect(Rect2(x + 4, y, 19, 5), Color("455037"))
			draw_rect(Rect2(x + 18, y, 5, 23), Color("455037"))
			draw_rect(Rect2(x + 7, y + 18, 16, 5), Color("455037"))
			draw_rect(Rect2(x + 7, y + 10, 5, 11), Color("455037"))
	for p in [Vector2(93, 11), Vector2(795, 527), Vector2(406, 0)]:
		draw_rect(Rect2(p, Vector2(8, 5)), Color("5c684b"))

func _draw_vine(start: Vector2, length: int, mirrored: bool) -> void:
	for i in range(length / 8):
		var bend := roundf(sin(i * 0.4) * 8 + sin(clock * 0.8 + i * 0.2) * 1.3)
		var p := start + Vector2(bend * (-1 if mirrored else 1), i * 8)
		draw_rect(Rect2(p, Vector2(4, 10)), Color("51663d"))
		draw_rect(Rect2(p + Vector2(0, 0), Vector2(2, 7)), Color("91a752"))
		if i % 3 == 1:
			var side := -1 if i % 2 else 1
			draw_rect(Rect2(p + Vector2(side * 5, 1), Vector2(8, 5)), Color("788f47"))
			draw_rect(Rect2(p + Vector2(side * 7, 0), Vector2(4, 3)), Color("a5b864"))

func _draw_totem(p: Vector2, mirrored: bool) -> void:
	var flip := -1 if mirrored else 1
	draw_rect(Rect2(p + Vector2(-43, 115), Vector2(86, 11)), Color("4e5b43"))
	draw_rect(Rect2(p + Vector2(-30, -26), Vector2(60, 140)), Color("4e5b43"))
	draw_rect(Rect2(p + Vector2(-26, -30), Vector2(51, 134)), Color("929575"))
	draw_rect(Rect2(p + Vector2(-23, -28), Vector2(5, 124)), Color("b3b38a"))
	draw_rect(Rect2(p + Vector2(-32, -52), Vector2(66, 39)), Color("9fa07b"))
	draw_rect(Rect2(p + Vector2(-29, -48), Vector2(58, 29)), Color("5a654a"))
	draw_rect(Rect2(p + Vector2(-24, -64), Vector2(12, 22)), Color("9fa07b"))
	draw_rect(Rect2(p + Vector2(13, -64), Vector2(12, 22)), Color("9fa07b"))
	draw_rect(Rect2(p + Vector2(-19, -39), Vector2(12, 6)), Color("c9bd7c"))
	draw_rect(Rect2(p + Vector2(9, -39), Vector2(12, 6)), Color("c9bd7c"))
	draw_rect(Rect2(p + Vector2(-9, -29), Vector2(18, 14)), Color("8f9470"))
	for i in range(3):
		var y := i * 22 + 2
		draw_line(p + Vector2(-8 * flip, y), p + Vector2(8 * flip, y + 8), Color("5b674b"), 3)
		draw_line(p + Vector2(8 * flip, y + 8), p + Vector2(-8 * flip, y + 16), Color("5b674b"), 3)
	draw_rect(Rect2(p + Vector2(-35, 100), Vector2(70, 12)), Color("a0a07a"))
	draw_rect(Rect2(p + Vector2(-39, 110), Vector2(78, 7)), Color("b2ad80"))
	# Hairline cracks on the worn lower half.
	draw_line(p + Vector2(16, 75), p + Vector2(7, 81), Color("616d4f"), 2)
	draw_line(p + Vector2(7, 81), p + Vector2(11, 91), Color("616d4f"), 2)

func _draw_fire(p: Vector2, zoom: int) -> void:
	var flicker := int(clock * 7) % 3
	Art.block(self, p, zoom, Rect2(-9, 0, 18, 4), Color("434e36"))
	Art.block(self, p, zoom, Rect2(-11, -3, 22, 3), Color("c4b884"))
	Art.block(self, p, zoom, Rect2(-7, -10, 14, 7), Color("b88a47"))
	Art.block(self, p, zoom, Rect2(-5, -15 + flicker, 5, 12 - flicker), Color("d4aa58"))
	Art.block(self, p, zoom, Rect2(1, -19 - flicker, 4, 15 + flicker), Color("dcb25f"))
	Art.block(self, p, zoom, Rect2(-1, -10, 6, 7), Color("edcf79"))
	Art.block(self, p, zoom, Rect2(2, -8, 2, 5), Color("f4df98"))

func _show_animations() -> void:
	_open_popup("animations",L.t("KARAKTERLER VE YOL ARKADAŞLARI"))
	popup.custom_minimum_size.x = 856
	var gallery = load("res://scripts/character_gallery.gd").new()
	stack.add_child(gallery)
	_body(L.t("Bekleme, koşu, saldırı ve ölüm animasyonları sırayla gösterilir."))
	_popup_button(L.t("ÖLÜM EKRANINI ÖNİZLE"), _preview_death)
	_popup_button(L.t("GERİ"), _close_popup)

func _preview_death() -> void:
	var screen = load("res://scripts/death_screen.gd").new()
	screen.sound_enabled = audio_enabled
	content.add_child(screen)
	screen.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	screen.size = DESIGN
	music.stream_paused = true
	screen.chosen.connect(func(_action): screen.queue_free(); music.stream_paused = false)


func _change_language(index: int) -> void:
	L.set_locale("en" if index == 1 else "tr")
	_save_settings()
	call_deferred("_rebuild_language")

func _rebuild_language() -> void:
	content.queue_free()
	cards.clear()
	rating_labels.clear()
	rating_bars.clear()
	content = Control.new()
	content.size = DESIGN
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(content)
	_build_menu()
	_build_popup()
	_layout()
	_refresh_cards()
	_show_settings()

func _show_flags() -> void:
	_open_popup("flags",L.t("BAYRAĞIN VE KEDİN"))
	_body(L.t("Koşu başına iki kez, bulunduğun yere bayrak ve kedi bırak. Son ölüm noktası ayrıca işaretlenir; hak tüketmez.")).add_theme_font_size_override("font_size",16)
	var preview = load("res://scripts/marker_preview.gd").new()
	preview.flag_code = selected_flag
	stack.add_child(preview)
	var picker := OptionButton.new()
	picker.custom_minimum_size.y = 38
	var flags := Markers.flags()
	for code in flags: picker.add_icon_item(Markers.texture(code),code)
	picker.add_theme_constant_override("icon_max_width",28)
	picker.select(flags.find(selected_flag))
	picker.item_selected.connect(func(index): selected_flag = flags[index]; preview.flag_code = selected_flag; _save_settings())
	stack.add_child(picker)
	_body(L.t("Kedi dekoratiftir. Savaşmaz, ödül toplamaz. Bayraklar ülke kodlarıyla listelenir.")).add_theme_font_size_override("font_size",14)
	_popup_button(L.t("KAYDET VE DON"),_close_popup)

func _show_enemies() -> void:
	_open_popup("enemies",L.t("KARANLIĞIN ORDUSU"))
	popup.custom_minimum_size.x=856
	stack.add_child(load("res://scripts/enemy_gallery.gd").new())
	_body(L.t("Kat gücü: %50 → %75 → Madness. Dalga 10: sunağı bul ve bossu çağır.\nBoss ölünce uzakta portal açılır. Portala girmeden kat değişmez.")).add_theme_font_size_override("font_size",14)
	_popup_button(L.t("GERI"),_close_popup)
