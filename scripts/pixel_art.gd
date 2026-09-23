extends RefCounted
## Original bitmap lettering and menu illustrations drawn as integer rectangles.
const GLYPHS := {
	"A": ["01110","11011","11011","11111","11011","11011","11011"],
	"B": ["11110","11011","11011","11110","11011","11011","11110"],
	"C": ["01111","11000","11000","11000","11000","11000","01111"],
	"D": ["11110","11011","11011","11011","11011","11011","11110"],
	"E": ["11111","11000","11000","11110","11000","11000","11111"],
	"F": ["11111","11000","11000","11110","11000","11000","11000"],
	"G": ["01111","11000","11000","11011","11011","11011","01111"],
	"H": ["11011","11011","11011","11111","11011","11011","11011"],
	"I": ["111","010","010","010","010","010","111"],
	"J": ["00111","00011","00011","00011","11011","11011","01110"],
	"K": ["11011","11011","11110","11100","11110","11011","11011"],
	"L": ["11000","11000","11000","11000","11000","11000","11111"],
	"M": ["11011","11111","11111","11011","11011","11011","11011"],
	"N": ["11011","11111","11111","11111","11011","11011","11011"],
	"O": ["01110","11011","11011","11011","11011","11011","01110"],
	"P": ["11110","11011","11011","11110","11000","11000","11000"],
	"Q": ["01110","11011","11011","11011","11111","01110","00011"],
	"R": ["11110","11011","11011","11110","11110","11011","11011"],
	"S": ["01111","11000","11000","01110","00011","00011","11110"],
	"T": ["11111","01110","01110","01110","01110","01110","01110"],
	"U": ["11011","11011","11011","11011","11011","11011","01110"],
	"V": ["11011","11011","11011","11011","11011","01110","00100"],
	"W": ["11011","11011","11011","11011","11111","11111","01010"],
	"X": ["11011","11011","01110","00100","01110","11011","11011"],
	"Y": ["11011","11011","01110","00100","00100","00100","00100"],
	"Z": ["11111","00011","00110","01100","11000","11000","11111"],
	"0": ["01110","11011","11011","11011","11011","11011","01110"],
	"1": ["01100","11100","01100","01100","01100","01100","11110"],
	"2": ["11110","00011","00011","01110","11000","11000","11111"],
	"3": ["11110","00011","00011","01110","00011","00011","11110"],
	"4": ["11011","11011","11011","11111","00011","00011","00011"],
	"5": ["11111","11000","11000","11110","00011","00011","11110"],
	"6": ["01110","11000","11000","11110","11011","11011","01110"],
	"7": ["11111","00011","00011","00110","01100","01100","01100"],
	"8": ["01110","11011","11011","01110","11011","11011","01110"],
	"9": ["01110","11011","11011","01111","00011","00011","01110"],
	"-": ["000","000","000","111","000","000","000"],
	".": ["0","0","0","0","0","1","1"],
	"/": ["00001","00011","00110","00100","01100","11000","10000"],
	">": ["100","110","011","001","011","110","100"],
	"+": ["00000","00100","00100","11111","00100","00100","00000"]
}

static func clean(value: String) -> String:
	return value.to_upper().replace("İ", "I").replace("Ş", "S").replace("Ç", "C").replace("Ğ", "G").replace("Ü", "U").replace("Ö", "O")

static func width(value: String, pixel: int, spacing := 1) -> float:
	var count := 0
	for character in clean(value):
		count += (GLYPHS[character][0].length() if GLYPHS.has(character) else 3) + spacing
	return maxf(0, count - spacing) * pixel

static func lettering(canvas: CanvasItem, value: String, point: Vector2, pixel: int, color: Color, spacing := 1) -> void:
	var cursor := point.round()
	for character in clean(value):
		if not GLYPHS.has(character):
			cursor.x += (3 + spacing) * pixel
			continue
		var rows: Array = GLYPHS[character]
		for y in range(7):
			for x in range(rows[y].length()):
				if rows[y][x] == "1":
					canvas.draw_rect(Rect2(cursor + Vector2(x, y) * pixel, Vector2.ONE * pixel), color)
		cursor.x += (rows[0].length() + spacing) * pixel

static func centered(canvas: CanvasItem, value: String, center_x: float, y: float, pixel: int, color: Color, spacing := 1) -> void:
	lettering(canvas, value, Vector2(center_x - width(value, pixel, spacing) / 2, y), pixel, color, spacing)

static func block(canvas: CanvasItem, origin: Vector2, zoom: int, rect: Rect2, color: Color) -> void:
	canvas.draw_rect(Rect2(origin + rect.position * zoom, rect.size * zoom), color)

static func hero(canvas: CanvasItem, index: int, feet: Vector2, zoom := 2, dim := false) -> void:
	var origin := feet.round()
	var colors := [Color("777c56"), Color("817797"), Color("69855b"), Color("718b8b"), Color("a67f52")]
	var cloth: Color = colors[index]
	var skin := Color("c3b183")
	var gold := Color("d0be7f")
	var steel := Color("b6b89b")
	var dark := Color("393d32")
	if dim:
		cloth = cloth.lerp(Color("535c4a"), 0.65)
		skin = skin.darkened(0.3)
		gold = gold.darkened(0.25)
		steel = steel.darkened(0.3)
	block(canvas, origin, zoom, Rect2(-10, -1, 20, 3), Color(0.13, 0.16, 0.13, 0.45))
	block(canvas, origin, zoom, Rect2(-9, -21, 18, 19), cloth.darkened(0.25))
	block(canvas, origin, zoom, Rect2(-6, -7, 5, 8), dark)
	block(canvas, origin, zoom, Rect2(2, -7, 5, 8), dark)
	block(canvas, origin, zoom, Rect2(-7, -21, 14, 15), cloth)
	block(canvas, origin, zoom, Rect2(-5, -30, 10, 11), skin)
	block(canvas, origin, zoom, Rect2(-6, -32, 12, 5), dark)
	block(canvas, origin, zoom, Rect2(-4, -34, 8, 3), cloth)
	block(canvas, origin, zoom, Rect2(-6, -24, 12, 3), dark)
	block(canvas, origin, zoom, Rect2(-4, -26, 2, 2), gold)
	block(canvas, origin, zoom, Rect2(2, -26, 2, 2), gold)
	block(canvas, origin, zoom, Rect2(-8, -12, 16, 3), dark)
	block(canvas, origin, zoom, Rect2(-2, -12, 4, 3), gold)
	block(canvas, origin, zoom, Rect2(-10, -20, 4, 10), skin)
	block(canvas, origin, zoom, Rect2(7, -20, 4, 10), skin)
	match index:
		0:
			block(canvas, origin, zoom, Rect2(11, -27, 3, 24), steel)
			block(canvas, origin, zoom, Rect2(8, -11, 9, 3), gold)
			block(canvas, origin, zoom, Rect2(-14, -20, 7, 12), dark)
			block(canvas, origin, zoom, Rect2(-13, -19, 5, 8), gold)
		1:
			block(canvas, origin, zoom, Rect2(12, -28, 2, 29), gold.darkened(0.25))
			block(canvas, origin, zoom, Rect2(10, -33, 6, 6), cloth.lightened(0.35))
			block(canvas, origin, zoom, Rect2(11, -32, 2, 2), Color("dbd2a0").darkened(0.25 if dim else 0))
			block(canvas, origin, zoom, Rect2(-8, -8, 16, 7), cloth)
		2:
			block(canvas, origin, zoom, Rect2(13, -23, 2, 17), gold)
			block(canvas, origin, zoom, Rect2(11, -26, 2, 3), gold)
			block(canvas, origin, zoom, Rect2(11, -6, 2, 3), gold)
			block(canvas, origin, zoom, Rect2(10, -23, 1, 18), skin)
			block(canvas, origin, zoom, Rect2(-9, -35, 3, 17), gold)
		3:
			block(canvas, origin, zoom, Rect2(12, -33, 2, 33), gold)
			block(canvas, origin, zoom, Rect2(11, -38, 4, 8), steel)
			block(canvas, origin, zoom, Rect2(-7, -32, 14, 4), steel)
		4:
			block(canvas, origin, zoom, Rect2(-10, -21, 20, 10), steel.darkened(0.25))
			block(canvas, origin, zoom, Rect2(12, -25, 3, 25), gold)
			block(canvas, origin, zoom, Rect2(8, -29, 12, 8), steel)

static func lock_icon(canvas: CanvasItem, point: Vector2, color: Color) -> void:
	canvas.draw_rect(Rect2(point + Vector2(2, 0), Vector2(6, 6)), color, false, 2)
	canvas.draw_rect(Rect2(point + Vector2(0, 5), Vector2(10, 7)), color)
	canvas.draw_rect(Rect2(point + Vector2(4, 7), Vector2(2, 3)), Color("414536"))
