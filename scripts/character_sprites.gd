extends RefCounted
const ROOT := "res://assets/characters/"
static var cache: Dictionary = {}
static var definitions: Dictionary = {}

static func sheet(file: String, cell: Vector2i, count: int, start := 0, fps := 10.0) -> Dictionary:
	return {"file": file, "cell": cell, "count": count, "start": start, "fps": fps}

static func setup() -> void:
	if not definitions.is_empty(): return
	definitions[0] = {}
	for pair in [["idle","_Idle",10],["run","_Run",10],["attack","_AttackNoMovement",4],["dash","_Roll",12],["hurt","_Hit",1],["death","_DeathNoMovement",10]]:
		definitions[0][pair[0]] = sheet("alp/" + pair[1] + ".png", Vector2i(120,80), pair[2])
	definitions[1] = {}
	for pair in [["idle",0,8],["run",1,8],["attack",2,13],["cast",4,17],["hurt",5,5],["death",6,9]]:
		definitions[1][pair[0]] = sheet("kam/sheet.png",Vector2i(160,128),pair[2],pair[1]*17)
	definitions[1]["dash"] = definitions[1]["run"]
	definitions[2] = {"idle":sheet("kiyat/Idle and running.png",Vector2i(64,64),2),"run":sheet("kiyat/Idle and running.png",Vector2i(64,64),8,8),"attack":sheet("kiyat/Normal Attack.png",Vector2i(64,64),11),"dash":sheet("kiyat/Dash.png",Vector2i(64,64),7,8),"death":sheet("kiyat/death.png",Vector2i(64,64),10,8)}
	definitions[3] = {}
	for pair in [["idle","Idle",8],["run","Run",8],["attack","Attacks",8],["dash","Roll",4],["hurt","Hurt",4],["death","Death",4]]:
		definitions[3][pair[0]] = sheet("yelme/"+pair[1]+".png",Vector2i(128,64),pair[2])
	definitions[4] = {}
	for pair in [["idle","Idle",64,15],["run","Run",96,8],["attack","Attack",144,22],["dash","Roll",180,15],["death","Death",96,15],["hurt","Shield",96,7]]:
		definitions[4][pair[0]] = sheet("cura/noBKG_Knight"+pair[1]+"_strip.png",Vector2i(pair[2],64),pair[3])
	definitions[5] = {}
	for pair in [["idle","Idle",4],["run","run",10],["attack","attack",17]]:
		definitions[5][pair[0]] = {"sequence":"hobbit/Hobbit - "+pair[1],"count":pair[2],"fps":10.0}
	definitions[6] = {"idle":sheet("bot/static idle.png",Vector2i(117,26),1),"run":sheet("bot/move without FX.png",Vector2i(117,26),8),"attack":sheet("bot/shoot with FX.png",Vector2i(117,26),4),"death":sheet("bot/death.png",Vector2i(117,26),6)}

static func frames(hero: int, state: String) -> Dictionary:
	setup()
	if not definitions[hero].has(state): state = "idle"
	var key := "%d/%s" % [hero,state]
	if cache.has(key): return cache[key]
	var d: Dictionary = definitions[hero][state]
	var list: Array[Texture2D] = []
	for i in range(d.count):
		if d.has("sequence"):
			list.append(load(ROOT + d.sequence + str(i+1) + ".png"))
		else:
			var texture: Texture2D = load(ROOT+d.file)
			var cols: int = texture.get_width() / d.cell.x
			var index: int = d.start+i
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(Vector2(index%cols,index/cols)*Vector2(d.cell),Vector2(d.cell))
			list.append(atlas)
	var bounds := list[0].get_image().get_used_rect()
	var anchor := Vector2(bounds.position.x+bounds.size.x/2.0,bounds.end.y)
	var data := {"list":list,"anchor":anchor,"height":maxi(bounds.size.y,1),"fps":d.fps}
	cache[key] = data
	return data

static func paint(canvas: CanvasItem, hero: int, state: String, time: float, feet: Vector2, height := 48.0, flip := false, dim := false) -> void:
	var d := frames(hero,state)
	var index := int(time*d.fps)
	if state in ["death","attack","hurt","dash","cast"]: index = mini(index,d.list.size()-1)
	else: index %= d.list.size()
	var idle := frames(hero,"idle")
	var scale_factor: float = height / idle.height
	var texture: Texture2D = d.list[index]
	canvas.draw_set_transform(feet,0,Vector2(-scale_factor if flip else scale_factor,scale_factor))
	canvas.draw_texture(texture,-d.anchor,Color("79816f") if dim else Color.WHITE)
	canvas.draw_set_transform(Vector2.ZERO)

static func pet_for(hero: int, level: int) -> int:
	if hero == 2: return -1
	if hero == 1: return 6 if level >= 30 else -1
	return 5 if level > 20 else -1
