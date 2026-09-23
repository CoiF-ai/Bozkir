extends Control
const L = preload("res://scripts/localization.gd")
const Sprites = preload("res://scripts/character_sprites.gd")
const Roster = preload("res://scripts/roster.gd")
var clock := 0.0
var state := "idle"
func _ready() -> void:
	custom_minimum_size = Vector2(800,275)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
func _process(dt: float) -> void:
	clock += dt
	state = ["idle","run","attack","death"][int(clock/2)%4]
	queue_redraw()
func _draw() -> void:
	var font := ThemeDB.fallback_font
	for i in range(5):
		var x := i*160.0
		draw_rect(Rect2(x+3,0,154,267),Color("28312d"))
		draw_string(font,Vector2(x+20,29),Roster.HEROES[i].name,HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("e3d29a"))
		var data := Sprites.frames(i,state)
		var time: float = fmod(clock,2.0)*data.list.size()/2.0/data.fps
		Sprites.paint(self,i,state,time,Vector2(x+77,150),75)
		draw_string(font,Vector2(x+15,183),{"idle":L.t("Bekleme"),"run":L.t("Koşu"),"attack":L.t("Saldırı"),"death":L.t("Ölüm")}[state],HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("b6c7b6"))
		var pet := Sprites.pet_for(i,30)
		if pet >= 0: Sprites.paint(self,pet,"run",clock,Vector2(x+80,230),34)
		draw_string(font,Vector2(x+12,258),[L.t("Hobbit • SV 21+"),L.t("Bot • SV 30+"),L.t("Pet yok"),L.t("Hobbit • geçici"),L.t("Hobbit • geçici")][i],HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("baab8f"))


