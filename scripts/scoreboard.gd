extends RefCounted
## Local completed-run records; no fabricated sample scores and no server.
const Roster = preload("res://scripts/roster.gd")
var path := "user://bozkir_scores.cfg"
var records: Array[Dictionary] = []

func read() -> void:
	records.clear()
	if path.is_empty():
		return
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return
	var raw: Variant = config.get_value("scores", "records", [])
	if not raw is Array:
		return
	for record in raw:
		if _valid(record):
			records.append(record.duplicate())
	_sort()

func _valid(record: Variant) -> bool:
	if not record is Dictionary:
		return false
	var chapter: Variant = record.get("chapter")
	var hero: Variant = record.get("hero")
	var seconds: Variant = record.get("seconds")
	return chapter is int and chapter > 0 and hero is int and hero >= 0 and hero < Roster.HEROES.size() and (seconds is float or seconds is int) and is_finite(float(seconds)) and seconds > 0

func add_completion(chapter: int, hero: int, seconds: float) -> Error:
	var record := {"chapter": chapter, "hero": hero, "seconds": seconds}
	if not _valid(record):
		return ERR_INVALID_DATA
	# Keep the personal best for each chapter and hero; slower retries cannot erase it.
	for i in range(records.size()):
		if records[i].chapter == chapter and records[i].hero == hero:
			if records[i].seconds <= seconds:
				return OK
			records.remove_at(i)
			break
	records.append(record)
	_sort()
	return save()

func _sort() -> void:
	records.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.seconds < b.seconds)
	if records.size() > 100:
		records.resize(100)

func save() -> Error:
	if path.is_empty():
		return OK
	var config := ConfigFile.new()
	config.set_value("scores", "records", records)
	return config.save(path)

static func duration(seconds: float) -> String:
	var ms := roundi(seconds * 1000)
	return "%02d:%02d.%03d" % [ms / 60000, (ms / 1000) % 60, ms % 1000]
