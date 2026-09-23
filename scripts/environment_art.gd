extends RefCounted
## Original code-native pixel scenery inspired by the user's three-tier reference.
const Rules = preload("res://scripts/campaign_rules.gd")

static func tree(canvas: CanvasItem, p: Vector2, clock: float, zoom := 1.0) -> void:
	var sway := roundf(sin(clock * 1.3 + p.x * 0.03) * 2)
	canvas.draw_rect(Rect2(p + Vector2(-5, -30) * zoom, Vector2(10, 34) * zoom), Color("675943"))
	canvas.draw_rect(Rect2(p + Vector2(-2, -28) * zoom, Vector2(3, 29) * zoom), Color("9d895e"))
	for cluster in [Vector2(-16, -41), Vector2(7, -46), Vector2(-5, -59)]:
		canvas.draw_rect(Rect2(p + (cluster + Vector2(sway, 0)) * zoom, Vector2(26, 20) * zoom), Color("284c3b"))
		canvas.draw_rect(Rect2(p + (cluster + Vector2(sway + 2, -2)) * zoom, Vector2(21, 15) * zoom), Color("4f7b45"))
		canvas.draw_rect(Rect2(p + (cluster + Vector2(sway + 4, -3)) * zoom, Vector2(13, 6) * zoom), Color("80a85a"))

static func crystal(canvas: CanvasItem, p: Vector2, clock: float, zoom := 1.0) -> void:
	var glow := (sin(clock * 2 + p.x) + 1) * 0.5
	canvas.draw_circle(p, 18 * zoom, Color(0.2, 0.65, 0.82, 0.06 + glow * 0.08))
	for i in range(3):
		var origin := p + Vector2(i * 7 - 7, 0) * zoom
		var height := (21 if i == 1 else 13) * zoom
		canvas.draw_colored_polygon(PackedVector2Array([origin + Vector2(-4, 0) * zoom, origin + Vector2(-4, -height * 0.7), origin + Vector2(0, -height), origin + Vector2(4, -height * 0.7), origin + Vector2(4, 0) * zoom]), Color("5d9fc5").lerp(Color("92e6e5"), glow * 0.4))
		canvas.draw_line(origin + Vector2(0, -height + 3), origin, Color("b0eeec"), 2 * zoom)

static func waterfall(canvas: CanvasItem, p: Vector2, height: float, clock: float, width := 15.0) -> void:
	canvas.draw_rect(Rect2(p, Vector2(width, height)), Color("4b9aba"))
	canvas.draw_rect(Rect2(p + Vector2(3, 0), Vector2(width * 0.4, height)), Color("88cee0"))
	for i in range(7):
		var y := fposmod(clock * 24 + i * 19, height)
		canvas.draw_rect(Rect2(p + Vector2(2 + i % 4, floor(y)), Vector2(width - 5, 2)), Color("c4e5e5"))
	canvas.draw_rect(Rect2(p + Vector2(-4, height), Vector2(width + 8, 3)), Color("a6e0e4"))

static func panorama(canvas: CanvasItem, area: Rect2, floor_index: int, clock: float) -> void:
	var palette: Dictionary = Rules.FLOORS[floor_index]
	canvas.draw_set_transform(area.position, 0, area.size / Vector2(480, 108))
	canvas.draw_rect(Rect2(0, 0, 480, 108), palette.sky)
	if floor_index == 0:
		for i in range(6):
			var x := fposmod(i * 97 + clock * 2, 520) - 20
			canvas.draw_rect(Rect2(floor(x), 10 + (i % 3) * 9, 45, 7), Color("d3e7df"))
			canvas.draw_rect(Rect2(floor(x) + 9, 5 + (i % 3) * 9, 23, 6), Color("edf0dc"))
		for i in range(9):
			var x := i * 62.0
			canvas.draw_colored_polygon(PackedVector2Array([Vector2(x - 20, 85), Vector2(x + 12, 20 + i % 3 * 9), Vector2(x + 42, 85)]), Color("669399"))
	elif floor_index == 1:
		for i in range(23):
			var x := i * 23.0
			canvas.draw_colored_polygon(PackedVector2Array([Vector2(x, 0), Vector2(x + 19, 0), Vector2(x + 8, 16 + i % 4 * 8)]), Color("101c31"))
	else:
		canvas.draw_rect(Rect2(0, 26, 480, 14), Color("b46847"))
		canvas.draw_rect(Rect2(0, 40, 480, 8), Color("d08b50"))
		for i in range(11):
			var x := i * 48.0 + 5
			canvas.draw_rect(Rect2(x, 12 + i % 3 * 7, 12, 70), Color("4d3b41"))
			canvas.draw_rect(Rect2(x - 3, 10 + i % 3 * 7, 18, 6), Color("4d3b41"))
	for i in range(5):
		var x := i * 104.0 - 10
		var y := 70.0 - (i % 3) * 13
		canvas.draw_colored_polygon(PackedVector2Array([Vector2(x, y), Vector2(x + 80, y), Vector2(x + 74, 101), Vector2(x + 31, 108), Vector2(x + 8, 92)]), palette.rock)
		canvas.draw_rect(Rect2(x, y, 82, 7), palette.ground)
		canvas.draw_rect(Rect2(x + 2, y, 77, 2), palette.accent)
		for stripe in range(5):
			canvas.draw_rect(Rect2(x + 11 + stripe * 12, y + 10, 3, 22 + stripe % 3 * 7), palette.rock.lightened(0.08))
		if i < 4:
			canvas.draw_line(Vector2(x + 80, y + 4), Vector2(x + 104, 70 - ((i + 1) % 3) * 13 + 4), Color("bd9e6d"), 2)
			for step in range(5):
				canvas.draw_rect(Rect2(x + 81 + step * 5, y + 4 + (step * (-2.6 if i % 3 < 2 else 5.2)), 4, 3), Color("907454"))
		if floor_index == 0:
			tree(canvas, Vector2(x + 39, y), clock, 0.65)
		elif floor_index == 1:
			crystal(canvas, Vector2(x + 44, y), clock, 1)
		else:
			canvas.draw_rect(Rect2(x + 25, y - 29, 9, 29), Color("968471"))
			canvas.draw_rect(Rect2(x + 23, y - 33, 13, 5), Color("b49b79"))
			canvas.draw_rect(Rect2(x + 50, y - 37, 3, 38), Color("94836a"))
			canvas.draw_rect(Rect2(x + 53, y - 36 + int(sin(clock * 3 + i)), 15, 14), Color("9c443c"))
	if floor_index < 2:
		waterfall(canvas, Vector2(165, 57), 47, clock)
		waterfall(canvas, Vector2(376, 70), 34, clock + 0.7, 11)
	else:
		canvas.draw_rect(Rect2(0, 101, 480, 7), Color("b9593e"))
		for i in range(22):
			var x := fposmod(i * 29 + clock * 14, 480)
			canvas.draw_rect(Rect2(floor(x), 102 + i % 3, 14, 2), Color("efb16b"))
	for i in range(14):
		var x := fposmod(i * 41 + clock * (4 + floor_index), 480)
		var y := fposmod(i * 19 - clock * 7, 98)
		canvas.draw_rect(Rect2(Vector2(x, y).floor(), Vector2(2, 2)), Color(palette.accent, 0.5))
	canvas.draw_set_transform(Vector2.ZERO)

static var terrain: Texture2D
static var ground_tiles: Array[Texture2D] = []

static func world(canvas: CanvasItem, arena: Rect2, view: Rect2, floor_index: int, clock: float) -> void:
	if terrain == null: terrain = load("res://assets/world/three-realms.png")
	if ground_tiles.is_empty():
		for biome in ["forest","cavern","ruins"]:
			ground_tiles.append(load("res://assets/world/%s-hd.png"%biome))
	var palette: Dictionary = Rules.FLOORS[floor_index]
	canvas.draw_rect(arena.grow(2000), palette.sky.darkened(0.6))
	# Decorative perimeter stays outside the walkable rectangle. All gameplay
	# objects and enemies retain their real world positions above this layer.
	var destination := Rect2(arena.position-Vector2(450,550),arena.size+Vector2(900,1100))
	var band_height := terrain.get_height()/3.0
	var source := Rect2(0,floor_index*band_height,terrain.get_width(),band_height)
	canvas.draw_texture_rect_region(terrain,destination,source)
	# Native-scale HD ground tiles replace the stretched low-resolution atlas
	# inside the playable area. The atlas supplies distant perimeter scenery only.
	canvas.draw_texture_rect(ground_tiles[floor_index],arena.grow(150),true)
	# Lightweight animated leaves / crystal motes / embers, with no light pass.
	for i in range(26):
		var position := Vector2(fposmod(i*173.0+clock*(9+floor_index*6),arena.size.x), fposmod(i*257.0-clock*(8+floor_index*4),arena.size.y))+arena.position
		if not view.has_point(position): continue
		var color: Color = [Color("c0d989"),Color("79d8ef"),Color("ffad65")][floor_index]
		color.a=0.35+0.25*sin(clock*1.6+i)
		canvas.draw_rect(Rect2(position.floor(),Vector2(3,2)),color)

