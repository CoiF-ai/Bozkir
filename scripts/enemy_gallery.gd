extends Control
const Art = preload("res://scripts/enemy_sprites.gd")
const L = preload("res://scripts/localization.gd")
var clock := 0.0
const ENTRIES := [
	["zombie","Zombi","Dalga 1+",32], ["monster","Karanlık Yaratık","Dalga 3+",49],
	["white","Beyaz Kurt","Dalga 5 • Orta",54], ["red","Kızıl Kurt","Dalga 7 • %70",54],
	["black","Alfa","Dalga 9 • Sürü",65], ["yelbegen_down","Yelbeğen","Kat 1 / 2 boss",72],
	["demon","Demon","4 dakika → Akın",51], ["spirit","Kan Ruhu","Portal öncesi tehdit",48],
	["dark","Karanlık Ruh","Kat 3 • Yerden çıkar",40], ["wizard","Evil Wizard","Kat 3 • Mini boss",66],
	["sorcerer","Son Büyücü","Kat 3 • Madness",75], ["portal","Ana Portal","Boss → Portal → Kat",0]
]
func _ready() -> void:
	custom_minimum_size=Vector2(800,318)
	mouse_filter=Control.MOUSE_FILTER_IGNORE
func _process(dt: float) -> void:
	clock+=dt
	queue_redraw()
func _draw() -> void:
	var font := ThemeDB.fallback_font
	for i in range(ENTRIES.size()):
		var data: Array=ENTRIES[i]
		var x := (i%4)*200.0
		var y := (i/4)*106.0
		draw_rect(Rect2(x+2,y+2,195,100),Color("20272b"))
		if data[0]=="portal":
			for ring in range(3): draw_arc(Vector2(x+43,y+55),15+ring*5,clock,clock+TAU*0.9,24,Color("77e8ba"),2)
		else:
			var frame := Art.frames(data[0],"idle")
			var height: float=minf(data[3],75.0*frame.height/frame.width)
			if data[0] in ["white","red","black"]: height=minf(height,34)
			Art.paint(self,data[0],"attack" if int(clock/2)%2 else "run",clock,Vector2(x+47,y+86),height)
		draw_string(font,Vector2(x+88,y+36),L.t(data[1]),HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("e5c6a1"))
		var label := L.t(data[2])
		var parts := label.split(" • ")
		draw_string(font,Vector2(x+88,y+60),parts[0],HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("c0b9b5"))
		if parts.size()>1: draw_string(font,Vector2(x+88,y+77),parts[1],HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("d47e8e"))
