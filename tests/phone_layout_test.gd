extends SceneTree
const Layout=preload("res://scripts/phone_layout.gd")
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	checks+=1
	if not ok: failures+=1; push_error(message)
func run() -> void:
	for resolution in [Vector2i(1280,720),Vector2i(2160,1080),Vector2i(2400,1080),Vector2i(2520,1080),Vector2i(2048,1536)]:
		root.size=resolution
		var game=load("res://scenes/main.tscn").instantiate()
		game.audio_enabled=false; game.profile_path=""; game.score_path=""
		root.add_child(game); game.set_process(false); game._start()
		await process_frame
		check(absf(root.get_visible_rect().size.aspect()-Vector2(resolution).aspect())<0.01,"Viewport expands to device aspect ratio")
		var safe := Layout.convert_safe(root.get_visible_rect().size,Vector2(resolution),Rect2(90,24,resolution.x-160,resolution.y-48))
		game._apply_safe_layout(safe)
		await process_frame
		for control in [game.ability,game.marker_button,game.inventory_button,game.pause_button]:
			check(safe.encloses(control.get_global_rect()),"Controls fit notch-safe %s"%resolution)
		var home: Vector2=game.pad.get_global_transform()*Vector2(90,game.pad.size.y-90)
		var event := InputEventScreenTouch.new()
		event.index=0; event.position=home+Vector2(40,0); event.pressed=true
		root.push_input(event,true)
		check(game.pad.direction.x>0.8,"Touch coordinates follow inset UI")
		event.pressed=false; root.push_input(event,true)
		game.queue_free(); await process_frame
	print("PHONE LAYOUT: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
