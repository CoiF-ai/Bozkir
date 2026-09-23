extends Node
const Library = preload("res://scripts/audio_library.gd")
var enabled := true
var settings_path := "user://bozkir_settings.cfg"
var music: AudioStreamPlayer
var voices: Array[AudioStreamPlayer] = []
var cache: Dictionary = {}
var effect_volume := 0.55
var music_volume := 0.35
var footstep_index := 0

func _ready() -> void:
	var config := ConfigFile.new()
	if not settings_path.is_empty() and config.load(settings_path) == OK:
		var fx: Variant = config.get_value("audio", "effects", 0.55)
		var bg: Variant = config.get_value("audio", "music", 0.35)
		if (fx is float or fx is int) and is_finite(float(fx)):
			effect_volume = clampf(fx, 0, 1)
		if (bg is float or bg is int) and is_finite(float(bg)):
			music_volume = clampf(bg, 0, 1)
		if config.get_value("audio", "muted", false) == true:
			music_volume = 0
	music = AudioStreamPlayer.new()
	add_child(music)
	music.volume_db = linear_to_db(maxf(0.0001, music_volume))
	for i in range(8):
		var voice := AudioStreamPlayer.new()
		add_child(voice)
		voices.append(voice)

func start_floor(index: int) -> void:
	if not enabled:
		return
	var stream: AudioStreamMP3 = load(Library.BATTLE_TRACKS[index]).duplicate()
	stream.loop = true
	music.stream = stream
	music.play()

func play_event(event: String, gain := 1.0) -> void:
	if not enabled or effect_volume <= 0 or not Library.SOUNDS.has(event):
		return
	var paths: Array = Library.SOUNDS[event]
	var path: String = paths[footstep_index % paths.size()] if event == "footstep" else paths.pick_random()
	if event == "footstep":
		footstep_index += 1
	if not cache.has(path):
		cache[path] = load(path)
	for voice in voices:
		if not voice.playing:
			voice.stream = cache[path]
			voice.volume_db = linear_to_db(maxf(0.0001, effect_volume * gain))
			voice.pitch_scale = 1.0
			voice.play()
			return

func pause_streams(paused: bool) -> void:
	music.stream_paused = paused
	for voice in voices:
		voice.stream_paused = paused
