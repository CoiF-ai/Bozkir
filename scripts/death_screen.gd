extends Control
const L = preload("res://scripts/localization.gd")
const Art = preload("res://scripts/pixel_art.gd")
signal chosen(action: String)
var clock := 0.0
var fracture := 0.0
var transitioning := false
var sound_enabled := true
var buttons: Array[Button] = []
var sound: AudioStreamPlayer

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 50
	sound = AudioStreamPlayer.new()
	sound.stream = load("res://assets/audio/death_drone.wav")
	var cfg := ConfigFile.new()
	var volume := 0.35
	if cfg.load("user://bozkir_settings.cfg") == OK:
		volume = clampf(float(cfg.get_value("audio","music",0.35)),0,1)
		if cfg.get_value("audio","muted",false): volume = 0
	sound.volume_db = linear_to_db(maxf(volume,0.0001))
	add_child(sound)
	if sound_enabled: sound.play()
	for item in [[L.t("YENİDEN BAŞLA"),"restart"],[L.t("ANA MENÜ"),"menu"]]:
		var button := Button.new()
		button.text = item[0]
		button.custom_minimum_size = Vector2(230,48)
		button.add_theme_font_size_override("font_size",20)
		add_child(button)
		button.pressed.connect(activate.bind(item[1]))
		buttons.append(button)
	resized.connect(layout)
	layout()

func layout() -> void:
	for i in range(buttons.size()):
		buttons[i].position = Vector2(size.x/2-245+i*260,size.y*0.78)
		buttons[i].size = Vector2(230,48)

func activate(action: String) -> void:
	if transitioning: return
	transitioning = true
	for button in buttons: button.disabled = true
	var tween := create_tween()
	tween.tween_property(self,"fracture",1.0,0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): sound.stop(); chosen.emit(action))

func _process(dt: float) -> void:
	clock += dt
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color(0.025,0.018,0.035,1.0))
	var font := ThemeDB.fallback_font
	var title := L.t("YOU DIED")
	draw_string(font,Vector2((size.x-font.get_string_size(title,HORIZONTAL_ALIGNMENT_LEFT,-1,56).x)/2,size.y*0.24),title,HORIZONTAL_ALIGNMENT_LEFT,-1,56,Color("d6c6ab"))
	var center := Vector2(size.x/2,size.y*0.50)
	var skull := ["0000111111110000","0011222222221100","0122222222222210","1222222222222221","1222222222222221","1220002222000221","1220002222000221","1220002222000221","0122222002222210","0012220002221100","0001222222210000","0001212121210000","0000110101100000"]
	var pixel := 12.0
	for y in range(skull.size()):
		for x in range(16):
			var value: String = skull[y][x]
			if value == "0": continue
			var half := -1.0 if x < 8 else 1.0
			var offset := Vector2(half*fracture*55,fracture*fracture*(25+absf(x-8)*7))
			var color := Color("d9cc9b") if value == "2" else Color("765263")
			color.a = 1.0-fracture*0.65
			draw_rect(Rect2(center+Vector2((x-8)*pixel,(y-6)*pixel)+offset,Vector2.ONE*pixel),color)
	if fracture > 0:
		var points := PackedVector2Array()
		for i in range(8): points.append(center+Vector2((-5 if i%2==0 else 7),-70+i*22))
		draw_polyline(points,Color("e77488"),2+fracture*5)
	draw_string(font,Vector2(size.x/2-149,size.y*0.70),L.t("Bozkır bir savaşçıyı daha bekliyor."),HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("9e879c"))


