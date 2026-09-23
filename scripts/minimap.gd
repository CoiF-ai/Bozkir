extends Control
var game: Node2D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	offset_left = -169
	offset_right = -21
	offset_top = 87
	offset_bottom = 182

func _process(_dt: float) -> void:
	queue_redraw()

func _map(pos: Vector2) -> Vector2:
	return Vector2(7, 7) + (pos - game.ARENA.position) / game.ARENA.size * (size - Vector2(14, 14))

func _draw() -> void:
	if not is_instance_valid(game) or game.mode == "title" or game.mode == "select":
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.025, 0.065, 0.08, 0.88))
	draw_rect(Rect2(Vector2.ZERO, size), Color("4b726b"), false, 1)
	for fountain in game.fountains:
		var p := _map(fountain.pos)
		var color := Color("6ad8a0") if game.economy.healing_ready(fountain.index) else Color("516359")
		draw_line(p - Vector2(3, 0), p + Vector2(3, 0), color, 2)
		draw_line(p - Vector2(0, 3), p + Vector2(0, 3), color, 2)
	for chest in game.chests:
		if not chest.opened:
			draw_rect(Rect2(_map(chest.pos) - Vector2(2, 2), Vector2(4, 4)), Color("e5bf6a"))
	for mark in game.placed_markers:
		if mark.floor == game.floor_index: draw_circle(_map(mark.pos),2,Color("80d5dd"))
	if not game.last_death.is_empty() and game.last_death.floor == game.floor_index:
		var point := _map(game.last_death.pos)
		draw_line(point-Vector2(3,3),point+Vector2(3,3),Color("ff8296"),2)
		draw_line(point-Vector2(3,-3),point+Vector2(3,-3),Color("ff8296"),2)
	if game.ritual_ready and not game.boss_defeated:
		draw_arc(_map(game.ritual_position),4,0,TAU,16,Color("c291ef"),2)
	if game.portal_active: draw_circle(_map(game.portal_position),4,Color("77e8ba"))
	draw_circle(_map(game.player), 3, Color("f2efd5"))
