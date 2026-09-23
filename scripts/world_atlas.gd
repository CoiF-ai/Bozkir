extends Control
const L = preload("res://scripts/localization.gd")
const Art = preload("res://scripts/environment_art.gd")
const Rules = preload("res://scripts/campaign_rules.gd")
var clock := 0.0
var animated := true
var panels: Array[Control] = []

func _ready() -> void:
	custom_minimum_size = Vector2(800, 315)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in range(3):
		var window := Control.new()
		window.position = Vector2(2, i * 105 + 2)
		window.size = Vector2(476, 96)
		window.clip_contents = true
		window.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(window)
		var art := Control.new()
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		window.add_child(art)
		art.draw.connect(func(): Art.panorama(art, Rect2(0, 0, 476, 96), i, clock))
		panels.append(art)

func _process(dt: float) -> void:
	if animated:
		clock += dt
		queue_redraw()

func _draw() -> void:
	for panel in panels:
		panel.queue_redraw()
	var font := ThemeDB.fallback_font
	for i in range(3):
		var y := i * 105.0
		var row := Rect2(0, y, 800, 100)
		var data: Dictionary = Rules.FLOORS[i]
		draw_rect(row, Color("35422f"))
		draw_string(font, Vector2(493, y + 24), L.t("%d. KAT • %s") % [i + 1, L.t(data.name)], HORIZONTAL_ALIGNMENT_LEFT, -1, 19, data.accent)
		draw_string(font, Vector2(493, y + 49), L.t("10. dalga → Boss → Portal"), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("e6e4c6"))
		draw_string(font, Vector2(493, y + 72), L.t("Düşman gücü %%%d • Altın ×%d") % [roundi(data.power * 100), data.gold], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("becaae"))
		draw_string(font, Vector2(493, y + 95), [L.t("Yapraklar • Bulutlar • Şelaleler"), L.t("Kristal parıltısı • Su • Toz"), L.t("Alevler • Lav akışı • Küller")][i], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("a7b794"))

