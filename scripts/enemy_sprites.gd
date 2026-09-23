extends RefCounted
const ROOT := "res://assets/enemies/"
static var manifest: Dictionary = {}
static var cache: Dictionary = {}
static func frames(key: String,state: String) -> Dictionary:
	if manifest.is_empty(): manifest = JSON.parse_string(FileAccess.get_file_as_string(ROOT+"manifest.json"))
	var id := key+"/"+state
	if cache.has(id): return cache[id]
	var data: Dictionary = manifest[key]
	var list: Array[Texture2D] = []
	if data.get("sequences",{}).has(state):
		for path in data.sequences[state]: list.append(_texture(ROOT+path))
	elif data.get("states",{}).has(state) or data.get("extra",{}).has(state):
		var spec: Array
		if data.get("extra",{}).has(state): spec = data.extra[state]
		else: spec = [data.file,data.cell[0],data.cell[1],data.states[state][0],data.states[state][1]]
		var texture: Texture2D = load(ROOT+spec[0])
		var cell := Vector2i(int(spec[1]),int(spec[2]))
		var cols := texture.get_width()/cell.x
		for i in range(int(spec[4])):
			var index := int(spec[3])+i
			var atlas := AtlasTexture.new()
			atlas.atlas=texture
			atlas.region=Rect2(Vector2(index%cols,index/cols)*Vector2(cell),Vector2(cell))
			list.append(atlas)
	else: return frames(key,"idle")
	var bounds := list[0].get_image().get_used_rect()
	var value := {"list":list,"anchor":Vector2(bounds.position.x+bounds.size.x/2.0,bounds.end.y),"width":maxi(1,bounds.size.x),"height":maxi(1,bounds.size.y)}
	cache[id]=value
	return value
static func paint(canvas: CanvasItem,key: String,state: String,time: float,feet: Vector2,height: float,flip := false,tint := Color.WHITE) -> void:
	var data := frames(key,state)
	var i := int(time*10)
	if state in ["death","emerge"]: i=mini(i,data.list.size()-1)
	else: i%=data.list.size()
	var scale_value: float = height/frames(key,"idle").height
	canvas.draw_set_transform(feet,0,Vector2(-scale_value if flip else scale_value,scale_value))
	canvas.draw_texture(data.list[i],-data.anchor,tint)
	canvas.draw_set_transform(Vector2.ZERO)
static func key(kind: int,variant: int,floor_index: int,direction := Vector2.DOWN) -> String:
	match kind:
		0: return "zombie"
		1: return "monster"
		2: return ["white","red","black"][clampi(variant,0,2)]
		3:
			if floor_index==2: return "sorcerer"
			var face := ("right" if direction.x>0 else "left") if absf(direction.x)>absf(direction.y) else ("down" if direction.y>0 else "up")
			return "yelbegen_"+face
		4: return "demon"
		5: return "spirit"
		6: return "dark"
	return "wizard"

static func _texture(path: String) -> Texture2D:
	var texture: Texture2D=load(path)
	if not "/sorcerer/" in path: return texture
	# Runtime color-key import: retain the supplied source, discard its flat backdrop.
	var image := texture.get_image()
	image.convert(Image.FORMAT_RGBA8)
	var background := image.get_pixel(0,0)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x,y)==background or (path.ends_with("/villain.png") and y<28):
				image.set_pixel(x,y,Color.TRANSPARENT)
	return ImageTexture.create_from_image(image)
