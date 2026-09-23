extends RefCounted
var modules: Dictionary = {}
var shield := 0.0
var shield_capacity := 0.0
var blocked_flash := 0.0
var charges := 0
var clock := 0.0
var pulse := 0.0
func reset() -> void:
	modules.clear(); shield=0; shield_capacity=0; blocked_flash=0; charges=0; clock=0; pulse=0
func equip(item: Dictionary, max_health := 100.0) -> void:
	var family: int=item.family
	var stacks := 1
	var data := item.duplicate(true)
	if modules.has(family):
		stacks=mini(3,modules[family].stacks+1)
		if modules[family].item.rank>item.rank: data=modules[family].item
	modules[family]={"item":data,"stacks":stacks,"cooldown":data.period if family in [0,6] else 0.0,"visual":0.0}
	if family==0:
		shield_capacity=strength(family)*2.0+max_health*0.2
		shield=shield_capacity
	if family==6: charges=3+data.tier
func strength(family: int) -> float:
	var module: Dictionary=modules[family]
	return module.item.power*(1.0+(module.stacks-1)*0.15)
func absorb(amount: float) -> float:
	var blocked := minf(shield,amount)
	shield-=blocked
	if blocked>0: blocked_flash=0.25
	return amount-blocked
func intercept(position: Vector2, player: Vector2) -> bool:
	if charges<=0 or not modules.has(6): return false
	if position.distance_to(player)>modules[6].item.radius: return false
	charges-=1
	return true
func retaliate(game: Node2D) -> void:
	if not modules.has(4): return
	for enemy in game.enemies:
		if enemy.emerge<=0 and enemy.pos.distance_to(game.player)<modules[4].item.radius:
			enemy.hp-=strength(4); enemy.flash=0.15
	modules[4].visual=0.3
func update(game: Node2D, dt: float) -> void:
	clock+=dt
	blocked_flash=maxf(0,blocked_flash-dt)
	for family in modules:
		var module: Dictionary=modules[family]
		module.visual=maxf(0,module.visual-dt)
		module.cooldown-=dt
		if family==4 or module.cooldown>0: continue
		var item: Dictionary=module.item
		module.cooldown=maxf(0.1,item.period)
		var power := strength(family)
		match family:
			0:
				shield_capacity=power*2.0+game.max_hp*0.2
				shield=shield_capacity
			6: charges=3+item.tier
			7: game.hp=minf(game.max_hp,game.hp+power*0.35); module.visual=0.4
			_: _attack(game,family,module,power)
func _attack(game: Node2D, family: int, module: Dictionary, power: float) -> void:
	var item: Dictionary=module.item
	var targets: Array[Dictionary]=[]
	for enemy in game.enemies:
		if enemy.emerge<=0 and enemy.hp>0 and enemy.pos.distance_to(game.player)<item.radius+enemy.radius:
			targets.append(enemy)
	if targets.is_empty(): return
	targets.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return a.pos.distance_squared_to(game.player)<b.pos.distance_squared_to(game.player))
	var direction: Vector2=(targets[0].pos-game.player).normalized()
	module.direction=direction
	module.visual=0.25
	var hits := 0
	for enemy in targets:
		var offset: Vector2=enemy.pos-game.player
		if family==2 and offset.normalized().dot(direction)<0.65: continue
		# Blades sweep the entire protected disk, including melee range. Sampling
		# only their orbit positions left an invulnerable hole next to the player.
		if family==8 and hits>=3: break
		hits+=1
		enemy.hp-=power*(0.22 if family in [1,2,5] else 1.0)
		enemy.flash=0.12
		if family==3: enemy.slow_time=2.0
		if family in [1,9] and enemy.kind!=3:
			enemy.pos=(enemy.pos+offset.normalized()*(10 if family==1 else 65)).clamp(game.ARENA.position+Vector2(20,20),game.ARENA.end-Vector2(20,20))
		if family==8: game._effect(enemy.pos,18,Color("b6b9ff"),0.2)
		if family==5 and hits<=3: game._effect(enemy.pos,12,Color("e4e9ef"),0.12)
func paint(game: Node2D) -> void:
	for family in modules:
		var module: Dictionary=modules[family]
		var radius: float=module.item.radius
		var center: Vector2=game.player
		match family:
			0:
				game.draw_arc(center,32,0,TAU,24,Color(0.2,0.4,0.55,0.3),2)
				if shield>0:
					game.draw_arc(center,32,-PI/2,-PI/2+TAU*shield/maxf(1,shield_capacity),32,Color(0.4,0.9,1.0,0.8),4)
				if blocked_flash>0: game.draw_circle(center,31,Color(0.4,0.9,1.0,blocked_flash))
			1:
				for i in range(3): game.draw_arc(center,radius*(0.45+i*0.2),clock*4+i,clock*4+i+2.4,16,Color(0.65,0.95,0.85,0.55),3)
			2:
				if module.visual>0 and module.has("direction"):
					for i in range(7):
						var direction: Vector2=module.direction.rotated((i-3)*0.16)
						game.draw_line(center,center+direction*radius,Color(1,0.35+i*0.05,0.06,0.55),5)
			5:
				for i in range(3):
					var direction := Vector2.from_angle(clock*3.5+i*TAU/3)
					var point: Vector2=center+direction*radius
					game.draw_line(center+direction*20,point,Color(0.75,0.85,0.95,0.35),2)
					game.draw_line(point-direction*18,point+direction*3,Color("e4e9ef"),4)
			6:
				if charges>0: game.draw_arc(center,42,-clock,TAU-clock,24,Color(0.7,0.5,1,0.55),2)
			_:
				if module.visual>0: game.draw_arc(center,radius*(1-module.visual),0,TAU,24,Color(0.6,0.85,1,module.visual*2),3)
