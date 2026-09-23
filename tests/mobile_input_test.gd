extends SceneTree
## Desktop synthetic touch checks; not a substitute for an Android device test.
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	checks += 1
	print(("PASS " if ok else "FAIL ") + label)
	if not ok: failures += 1
func touch(index: int, position: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = position
	event.pressed = pressed
	root.push_input(event, true)
func run() -> void:
	for resolution in [Vector2i(960,540),Vector2i(1280,720),Vector2i(2400,1080)]:
		root.size = resolution
		var game = load("res://scenes/main.tscn").instantiate()
		game.audio_enabled = false
		game.profile_path = ""
		game.score_path = ""
		root.add_child(game)
		current_scene = game
		game.set_process(false)
		game._start()
		await process_frame
		await process_frame
		var bounds := Rect2(Vector2.ZERO,root.get_visible_rect().size)
		for button in [game.ability,game.marker_button,game.inventory_button,game.pause_button]:
			check(bounds.encloses(button.get_global_rect()),"%s control fits: %s" % [resolution,button.text])
		var home: Vector2 = Vector2(90,game.pad.size.y-90)
		touch(0,home+Vector2(40,0),true)
		check(game.pad.direction.x>0.8,"First finger holds joystick")
		var start: Vector2 = game.player
		game._simulate(0.05)
		check(game.player.x>start.x,"Touch moves player")
		var dash: Vector2 = game.ability.get_global_rect().get_center()
		touch(1,dash,true)
		touch(1,dash,false)
		check(game.dash_cd>0 and game.dash_cd<=3.0,"Second finger dashes with three-second cooldown")
		check(game.pad.finger==0 and game.pad.direction.x>0.8,"Second finger release preserves joystick")
		var flag: Vector2 = game.marker_button.get_global_rect().get_center()
		for i in range(3):
			touch(1,flag,true)
			touch(1,flag,false)
		check(game.placed_markers.size()==2,"Touch flag limited to two placements")
		touch(0,home,false)
		check(game.pad.direction==Vector2.ZERO,"Joystick release stops movement")
		touch(0,home+Vector2(40,0),true)
		var pause: Vector2 = game.pause_button.get_global_rect().get_center()
		touch(1,pause,true)
		touch(1,pause,false)
		check(game.mode=="pause" and game.pad.direction==Vector2.ZERO,"Pause clears held touch")
		game._resume()
		check(game.pad.finger==-1,"Resume has no stuck finger")
		game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
		check(game.mode=="pause","App focus loss pauses gameplay")
		game.queue_free()
		await process_frame
	print("MOBILE INPUT: %d checks, %d failures (synthetic desktop touch)" % [checks,failures])
	quit(1 if failures else 0)
