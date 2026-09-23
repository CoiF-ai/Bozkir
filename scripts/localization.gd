extends RefCounted
static var locale := "tr"
static var english: Dictionary = {}
const TURKISH_MENU := {"PLAY":"OYNA","HELP":"YARDIM","SETTINGS":"AYARLAR","QUIT":"CIKIS","YOU DIED":"ÖLDÜN","SETTINGS  /  AYARLAR":"AYARLAR","HELP  /  NASIL OYNANIR?":"NASIL OYNANIR?"}
static func set_locale(value: String) -> void:
	locale = value if value in ["tr","en"] else "tr"
	TranslationServer.set_locale(locale)
static func t(value: String) -> String:
	if locale == "tr": return TURKISH_MENU.get(value,value)
	if english.is_empty():
		english = JSON.parse_string(FileAccess.get_file_as_string("res://localization/en.json"))
	return english.get(value,value)
