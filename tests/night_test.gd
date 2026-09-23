extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error(message)
func run() -> void:
	var game=load("res://scenes/main.tscn").instantiate()
	game.audio_enabled=false
	game.profile_path=""
	game.score_path=""
	root.add_child(game)
	game.set_process(false)
	game._start()
	game.elapsed=55
	check(not game._is_night(),"Daytime is not frenzy")
	var day_interval: float=game._spawn_interval()
	var day: Dictionary=game._enemy_stats(6,0)
	game.elapsed=112.5
	check(game._is_night(),"21:00 starts night")
	var night: Dictionary=game._enemy_stats(6,0)
	check(is_equal_approx(night.speed,day.speed*1.25),"Night movement +25 percent")
	check(is_equal_approx(night.attack_rate,day.attack_rate*1.35),"Night attacks +35 percent")
	check(is_equal_approx(night.damage,day.damage*1.15),"Night damage +15 percent")
	check(is_equal_approx(game._spawn_interval(),day_interval*0.6),"Night spawn interval -40 percent")
	game._spawn_group()
	check(game.enemies.size()==2,"Night wave one spawns two instead of one")
	game._update_vision()
	check(game.vision_material.get_shader_parameter("radius")==230.0,"Night sight radius")
	var enemy: Dictionary=game.enemies[0]
	var night_speed: float=enemy.speed
	game.scaling_cd=0
	game._update_encounter(0.01)
	check(is_equal_approx(enemy.speed,night_speed),"Night scaling does not stack")
	game.elapsed=180
	check(not game._is_night(),"06:00 ends night")
	game.scaling_cd=0
	game._update_encounter(0.01)
	check(is_equal_approx(enemy.speed,night_speed/1.25),"Existing enemy loses frenzy at dawn")
	game._update_vision()
	check(game.vision_material.get_shader_parameter("radius")==440.0,"Day restores sight radius")
	game.queue_free()
	await process_frame
	print("NIGHT: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
