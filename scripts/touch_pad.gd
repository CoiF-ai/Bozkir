extends Control
## Multi-touch joystick. Coordinates stay in viewport space on every aspect ratio.
var finger := -1
var origin := Vector2.ZERO
var stick := Vector2.ZERO
var direction := Vector2.ZERO
var active := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func reset() -> void:
	finger = -1
	direction = Vector2.ZERO
	stick = Vector2.ZERO
	active = false
	queue_redraw()

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	var home := Vector2(90, size.y - 90)
	var point := Vector2.ZERO
	if event is InputEventScreenTouch or event is InputEventScreenDrag or event is InputEventMouse:
		point = get_global_transform().affine_inverse()*event.position
	if event is InputEventScreenTouch:
		if event.pressed and finger == -1 and point.distance_to(home) < 85:
			finger = event.index
			origin = home
			active = true
			_update_stick(point)
		elif not event.pressed and event.index == finger:
			reset()
	elif event is InputEventScreenDrag and event.index == finger:
		_update_stick(point)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and point.distance_to(home) < 70 and finger == -1:
			origin = home
			finger = -2
			active = true
			_update_stick(point)
		elif not event.pressed and finger == -2:
			reset()
	elif event is InputEventMouseMotion and finger == -2:
		_update_stick(point)

func _update_stick(point: Vector2) -> void:
	stick = (point - origin).limit_length(44)
	direction = stick / 44.0
	queue_redraw()

func _draw() -> void:
	var home := Vector2(90, size.y - 90)
	draw_circle(home, 58, Color(0.03, 0.08, 0.1, 0.58))
	draw_arc(home, 58, 0, TAU, 48, Color(0.39, 0.75, 0.72, 0.35), 2)
	draw_circle(home + stick, 24, Color(0.35, 0.72, 0.7, 0.6))
	draw_line(home + stick + Vector2(-8, 0), home + stick + Vector2(8, 0), Color("c5ead6"), 2)
	draw_line(home + stick + Vector2(0, -8), home + stick + Vector2(0, 8), Color("c5ead6"), 2)
