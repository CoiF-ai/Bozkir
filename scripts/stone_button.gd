extends Button
const Sprites = preload("res://scripts/character_sprites.gd")
const Art = preload("res://scripts/pixel_art.gd")
var caption := "PLAY"
var font_pixel := 3
var hero_index := -1
var locked := false
var selected := false
var held := false
var animated := true
var timer := 0.0

func _ready() -> void:
	text = ""
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(state, StyleBoxEmpty.new())
	button_down.connect(func(): held = true; queue_redraw())
	button_up.connect(func(): held = false; queue_redraw())
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)

func _process(dt: float) -> void:
	if hero_index >= 0 and animated and selected:
		timer += dt
		queue_redraw()

func _draw() -> void:
	var depressed := held or is_pressed()
	var highlighted := is_hovered() or has_focus() or selected
	var shift := 3 if depressed else 0
	var surface := Rect2(Vector2(0, shift), size - Vector2(0, 5))
	draw_rect(Rect2(Vector2(3, 5), size - Vector2(3, 5)), Color("33392e"))
	draw_rect(surface, Color("dad09b") if highlighted else Color("b8b182"))
	draw_rect(surface.grow(-3), Color("414735"))
	draw_rect(surface.grow(-6), Color("a39e75") if highlighted else Color("8c8d69"))
	draw_rect(Rect2(Vector2(8, 7 + shift), Vector2(size.x - 16, 3)), Color("c0b889") if highlighted else Color("a7a77a"))
	draw_rect(Rect2(Vector2(9, size.y - 13 + shift), Vector2(size.x - 18, 2)), Color("686e51"))
	# Small chips keep the edge carved rather than mechanically uniform.
	draw_rect(Rect2(18, shift, 6, 3), Color("6a7154"))
	draw_rect(Rect2(size.x - 29, size.y - 8 + shift, 7, 3), Color("b7b180"))
	if hero_index < 0:
		Art.centered(self, caption, size.x / 2, floor((size.y - 7 * font_pixel) / 2) - 3 + shift, font_pixel, Color("343d30"))
		if highlighted and size.x > 180:
			Art.lettering(self, ">", Vector2(15, floor((size.y - 14) / 2) - 2 + shift), 2, Color("53663d"))
	else:
		var bob := floorf(sin(timer * 3) * 1.1) if animated and selected else 0.0
		Sprites.paint(self, hero_index, "idle", timer, Vector2(size.x / 2 - 2, 73 + shift + bob), 49, false, locked)
		Art.centered(self, caption, size.x / 2, 80 + shift, 1, Color("2e382e"), 2)
		if locked:
			Art.lock_icon(self, Vector2(size.x - 19, 12 + shift), Color("d6c894"))
		else:
			draw_rect(Rect2(10, 13 + shift, 3, 3), Color("dae4aa"))
		if selected:
			draw_rect(Rect2(size.x / 2 - 3, size.y - 12 + shift, 6, 3), Color("e9dfaa"))
