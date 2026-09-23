extends SceneTree
var failures := 0
var checks := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error(message)
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.audio_enabled = false
	game.profile_path = ""
	game.score_path = ""
	root.add_child(game)
	game.set_process(false)
	game._start()
	# Reproduce ranged monsters parked inside the old 215px stopping radius.
	for kind in [1,4,5,6,7]:
		for distance in [160.0,450.0]:
			game.enemies.clear()
			game.player = Vector2.ZERO
			game._spawn(kind,Vector2(distance,0))
			var enemy: Dictionary = game.enemies[0]
			enemy.emerge = 0
			enemy.cooldown = 100
			for i in range(30): game._update_enemies(1.0/60)
			check(enemy.pos.distance_to(game.player)<distance-5,"Enemy %d pursues from %.0fpx"%[kind,distance])
			game.player = Vector2(distance,300)
			var initial: float = enemy.pos.distance_to(game.player)
			for i in range(30): game._update_enemies(1.0/60)
			check(enemy.pos.distance_to(game.player)<initial-5,"Enemy reacquires changed player position")
	var distances: Array[float] = []
	for fps in [10,15,30,60]:
		game._start()
		game.spawn_cd = 100
		game.player = Vector2.ZERO
		game.pad.direction = Vector2.RIGHT
		for i in range(fps): game._advance_simulation(1.0/fps)
		distances.append(game.player.x)
		check(absf(game.elapsed-1)<0.001,"Elapsed time preserved at %d FPS"%fps)
		check(absf(game.player.x-game.speed)<0.1,"Full movement speed at %d FPS"%fps)
	check(distances.max()-distances.min()<0.1,"10-60 FPS equal displacement")
	game._pause()
	var paused: float = game.elapsed
	game._advance_simulation(1.0)
	check(game.elapsed==paused,"Paused time is not simulated")
	game._resume()
	game._advance_simulation(1.0/60)
	check(absf(game.elapsed-paused-1.0/60)<0.001,"No catch-up burst after pause")
	game.queue_free()
	await process_frame
	print("PACE/PURSUIT: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
