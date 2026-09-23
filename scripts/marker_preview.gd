extends Control
const Markers = preload("res://scripts/trail_markers.gd")
var flag_code := "TR"
var clock := 0.0
func _ready() -> void:
	custom_minimum_size = Vector2(450,100)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
func _process(dt: float) -> void:
	clock += dt
	queue_redraw()
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color("29352e"))
	Markers.paint(self,Vector2(size.x/2-25,76),flag_code,clock)
