extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	checks+=1
	if not ok: failures+=1; push_error(message)
func run() -> void:
	var game=load("res://scenes/main.tscn").instantiate()
	game.audio_enabled=false; game.profile_path=""; game.score_path=""
	root.add_child(game); game.set_process(false)
	for hero in range(5):
		game.selected_hero=hero
		for i in range(8):
			game._start(); game.spawn_cd=999; game.player=Vector2.ZERO
			var direction := Vector2.from_angle(i*TAU/8)
			game.pad.direction=direction
			game._simulate(1.0/60)
			check(game.player.normalized().dot(direction)>0.99,"All eight movement directions")
			game._dash()
			check(game.dash_cd==3 and game.dash_left>0,"Hero ability starts with 3-second cooldown")
			var origin: Vector2=game.player
			for j in range(90): game._simulate(1.0/60)
			check(game.player.distance_to(origin)>30 and game.dash_left==0,"Ability advances and completes")
	game.selected_hero=1; game._start(); game.player=Vector2.ZERO
	game.movement_direction=Vector2.RIGHT; game.moving=true; game._dash()
	game.hero_motion.advance(game,Vector2.UP,0.2)
	check(game.player.y<0 and game.hero_motion.height(game.dash_left)>0,"Kam steers while airborne")
	var hp: float=game.hp
	game._hurt(100)
	check(game.hp==hp,"Flight avoids damage while airborne")
	game.selected_hero=2; game._start(); game.player=Vector2.ZERO; game.facing=Vector2.RIGHT; game.moving=false
	game._spawn(0,Vector2(200,0)); game.enemies[0].emerge=0
	game._dash()
	check(game.hero_motion.anchor==Vector2(200,0),"Hook locks to a target ahead")
	for i in range(30): game.hero_motion.advance(game,Vector2.ZERO,1.0/60)
	check(game.player.distance_to(Vector2(200,0))<1,"Hook reaches anchor without overshoot")
	game.selected_hero=3; game._start(); game.player=Vector2.ZERO; game.facing=Vector2.RIGHT; game.moving=false
	game._spawn(0,Vector2(260,0)); game.enemies[0].emerge=0; game.enemies[0].hp=1000
	game._dash()
	for i in range(45): game.hero_motion.advance(game,Vector2.ZERO,1.0/60)
	check(game.enemies[0].hp<1000 and game.enemies[0].pos.x>=260,"Yelme landing damages nearby enemy")
	var after: float=game.enemies[0].hp
	# Completed abilities must not repeat their landing attack.
	game.hero_motion.advance(game,Vector2.ZERO,1.0/60)
	check(game.enemies[0].hp==after,"Landing triggers once")
	game.selected_hero=4; game._start(); game.player=Vector2.ZERO
	for i in range(8):
		game._spawn(0,Vector2.from_angle(i*TAU/8)*75)
		game.enemies[-1].emerge=0; game.enemies[-1].hp=1000
	game._dash(); game.hero_motion.advance(game,Vector2.ZERO,0.1)
	for enemy in game.enemies: check(enemy.hp<1000,"Cura spin hits every direction")
	game.queue_free(); await process_frame
	print("HERO MOTION: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
