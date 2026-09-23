extends RefCounted
static var codes: Array = []
static var textures: Dictionary = {}
static var cat_texture: Texture2D
static func flags() -> Array:
	if codes.is_empty(): codes = JSON.parse_string(FileAccess.get_file_as_string("res://assets/flags/codes.json"))
	return codes
static func valid_flag(code: String) -> String:
	return code if code in flags() else "TR"
static func texture(code: String) -> Texture2D:
	code = valid_flag(code)
	if not textures.has(code): textures[code] = load("res://assets/flags/"+code+".png")
	return textures[code]
static func paint(canvas: CanvasItem, point: Vector2, code: String, time: float, death := false) -> void:
	canvas.draw_line(point,point+Vector2(0,-48),Color("d5c4a0"),3)
	canvas.draw_texture_rect(texture(code),Rect2(point+Vector2(2,-47),Vector2(34,24)),false)
	if cat_texture == null: cat_texture = load("res://assets/cat/IDLE.png")
	canvas.draw_texture_rect_region(cat_texture,Rect2(point+Vector2(15,-34),Vector2(64,51)),Rect2(int(time*8)%8*80,0,80,64))
	if death:
		canvas.draw_arc(point+Vector2(0,3),17,0,TAU,24,Color("df7d8d"),2)
static func save_death(path: String, floor_index: int, point: Vector2, code: String) -> Error:
	if path.is_empty(): return OK
	var cfg := ConfigFile.new()
	cfg.set_value("death","floor",floor_index)
	cfg.set_value("death","position",point)
	cfg.set_value("death","flag",valid_flag(code))
	return cfg.save(path)
static func read_death(path: String) -> Dictionary:
	if path.is_empty(): return {}
	var cfg := ConfigFile.new()
	if cfg.load(path)!=OK: return {}
	var floor_value: Variant = cfg.get_value("death","floor",-1)
	var point: Variant = cfg.get_value("death","position",null)
	if not floor_value is int or floor_value<0 or floor_value>2 or not point is Vector2: return {}
	if not point.is_finite() or not Rect2(-2100,-1300,4200,2600).has_point(point): return {}
	return {"floor":floor_value,"pos":point,"flag":valid_flag(str(cfg.get_value("death","flag","TR")))}

