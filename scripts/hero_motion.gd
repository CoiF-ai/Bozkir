extends RefCounted
const NAMES := ["FIRLAMA","UÇUŞ","KANCA","SIÇRAMA","DÖNER KILIÇ"]
const DURATIONS := [0.25,1.1,0.4,0.65,0.8]
var kind := 0
var duration := 0.25
var anchor := Vector2.ZERO
var origin := Vector2.ZERO
var spin_cd := 0.0
func begin(game: Node2D) -> void:
	kind=game.selected_hero
	duration=DURATIONS[kind]
	game.dash_left=duration
	game.dash_cd=game.DASH_COOLDOWN
	game.dash_direction=(game.movement_direction if game.moving else game.facing).normalized()
	if game.dash_direction==Vector2.ZERO: game.dash_direction=Vector2.RIGHT
	origin=game.player
	anchor=(game.player+game.dash_direction*320).clamp(game.ARENA.position+Vector2(25,25),game.ARENA.end-Vector2(25,25))
	if kind==2:
		var best := 420.0
		for enemy in game.enemies:
			var offset: Vector2=enemy.pos-game.player
			if enemy.emerge<=0 and offset.length()<best and offset.normalized().dot(game.dash_direction)>0.65:
				best=offset.length(); anchor=enemy.pos
		game.dash_direction=(anchor-game.player).normalized()
	game.immunity=maxf(game.immunity,duration if kind in [1,3] else 0.3)
	spin_cd=0
	for enemy in game.enemies: enemy.dash_hit=false
func advance(game: Node2D, movement: Vector2, dt: float) -> void:
	if game.dash_left<=0: return
	var step: float=minf(dt,game.dash_left)
	match kind:
		0: game.player+=game.dash_direction*780*step
		1:
			if movement.length()>0.1: game.dash_direction=movement.normalized()
			game.player+=game.dash_direction*game.speed*1.65*step
		2: game.player=game.player.move_toward(anchor,900*step)
		3: game.player+=game.dash_direction*400*step
		4:
			game.player+=movement*game.speed*1.25*step
			spin_cd-=step
			if spin_cd<=0:
				spin_cd=0.16
				_burst(game,110,game.damage*0.7,0)
	game.player=game.player.clamp(game.ARENA.position+Vector2(25,25),game.ARENA.end-Vector2(25,25))
	game.dash_left=maxf(0,game.dash_left-dt)
	if game.dash_left<=0 and kind==3:
		_burst(game,145,game.damage*2.5,55)
		game._effect(game.player,145,Color("e9bd82"),0.4)
func _burst(game: Node2D, radius: float, damage: float, push: float) -> void:
	for enemy in game.enemies:
		if enemy.emerge>0 or enemy.pos.distance_to(game.player)>radius+enemy.radius: continue
		enemy.hp-=damage
		enemy.flash=0.2
		var offset: Vector2=enemy.pos-game.player
		var direction: Vector2=offset.normalized() if offset.length()>1 else game.dash_direction
		if enemy.kind!=3: enemy.pos=(enemy.pos+direction*push).clamp(game.ARENA.position+Vector2(20,20),game.ARENA.end-Vector2(20,20))
func height(remaining: float) -> float:
	if remaining<=0: return 0
	var progress := clampf(1.0-remaining/duration,0,1)
	return sin(progress*PI)*(48.0 if kind==1 else 70.0 if kind==3 else 12.0 if kind==0 else 0.0)
func paint(game: Node2D) -> void:
	if game.dash_left<=0: return
	if kind==2:
		game.draw_line(game.player+Vector2(0,-20),anchor,Color("dfd5b0"),2)
		game.draw_arc(anchor,9,0,PI*1.6,10,Color("faf0c9"),3)
	elif kind==4:
		var angle: float=(duration-game.dash_left)*TAU*5
		for i in range(2):
			var direction := Vector2.from_angle(angle+i*PI)
			game.draw_line(game.player+direction*24,game.player+direction*105,Color("edddb0"),5)
			game.draw_arc(game.player,100,angle+i*PI-1,angle+i*PI,14,Color(0.8,0.9,1,0.5),3)
	elif kind==1:
		game.draw_arc(game.player,35,0,TAU,24,Color(0.65,0.45,0.9,0.5),3)
