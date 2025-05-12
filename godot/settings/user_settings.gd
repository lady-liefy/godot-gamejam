## Autoload UserSettings
extends Node

signal on_value_change(key, value)

const SECTION = "user"
const SETTINGS_FILE = "user://settings.cfg"

const MASTERVOLUME_ENABLED = "mastervolume_enabled"
const MUSICVOLUME_ENABLED = "musicvolume_enabled"
const SOUNDVOLUME_ENABLED = "soundvolume_enabled"
const MASTERVOLUME = "mastervolume"
const MUSICVOLUME = "musicvolume"
const SOUNDVOLUME = "soundvolume"
const GAME_LANGUAGE = "game_locale"

const AUDIO_BUS_MASTER = "Master"
const AUDIO_BUS_SOUND = "Sound"
const AUDIO_BUS_MUSIC = "Music"

const RESOLUTION = "resolution"
const VSYNC_ENABLED = "vsync_enabled"
const FULLSCREEN_ENABLED = "fullscreen_enabled"

var USER_SETTING_DEFAULTS = {
	MASTERVOLUME_ENABLED:true,
	MUSICVOLUME_ENABLED:true,
	SOUNDVOLUME_ENABLED:true,
	MASTERVOLUME:100,
	MUSICVOLUME:70,
	SOUNDVOLUME:100,
	GAME_LANGUAGE:"en",
	RESOLUTION:Vector2(1280,720),
	VSYNC_ENABLED:false,
	FULLSCREEN_ENABLED:false
}

var RESOLUTION_CHOICES : Array[Vector2i] = [
	Vector2i(640, 360),
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440)
]

var config:  ConfigFile

func _ready() -> void:
	config = ConfigFile.new()
	config.load(SETTINGS_FILE)
	_configure_audio()
	_configure_visuals()
	_configure_language()
	
func set_value(key, value) -> void:
	config.set_value(SECTION, key, value)
	config.save(SETTINGS_FILE)
	
	# Audio
	if key == MASTERVOLUME:
		_update_volume(MASTERVOLUME, AUDIO_BUS_MASTER)
	if key == SOUNDVOLUME:
		_update_volume(SOUNDVOLUME, AUDIO_BUS_SOUND)
	if key == MUSICVOLUME:
		_update_volume(MUSICVOLUME, AUDIO_BUS_MUSIC)
	if key == MASTERVOLUME_ENABLED:
		_mute_bus(MASTERVOLUME_ENABLED, AUDIO_BUS_MASTER)
	if key == MUSICVOLUME_ENABLED:
		_mute_bus(MUSICVOLUME_ENABLED, AUDIO_BUS_MUSIC)
	if key == SOUNDVOLUME_ENABLED:
		_mute_bus(SOUNDVOLUME_ENABLED, AUDIO_BUS_SOUND)
	if key == GAME_LANGUAGE:
		TranslationServer.set_locale(value)
	
	# Visual
	if key == VSYNC_ENABLED:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if value else DisplayServer.VSYNC_DISABLED)
	if key == FULLSCREEN_ENABLED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if value else DisplayServer.WINDOW_MODE_WINDOWED)
	if key == RESOLUTION:
		DisplayServer.window_set_size(value)
	
	on_value_change.emit(key, value)

func get_value(key):
	return config.get_value(SECTION, key, _get_default(key))

func get_value_with_default(key, default):
	var value = config.get_value(SECTION, key, default)
	if value == null or default == null:  # If the value doesn't exist, fall back to default
		value = default
		config.set_value(SECTION, key, default)
		config.save(SETTINGS_FILE)
	return value

func _get_default(key):
	if USER_SETTING_DEFAULTS.has(key):
		return USER_SETTING_DEFAULTS[key]
	return null

func _configure_audio() -> void:
	_update_volume(MASTERVOLUME, AUDIO_BUS_MASTER)
	_update_volume(MUSICVOLUME, AUDIO_BUS_MUSIC)
	_update_volume(SOUNDVOLUME, AUDIO_BUS_SOUND)
	_mute_bus(MASTERVOLUME_ENABLED, AUDIO_BUS_MASTER)
	_mute_bus(MUSICVOLUME_ENABLED, AUDIO_BUS_MUSIC)
	_mute_bus(SOUNDVOLUME_ENABLED, AUDIO_BUS_SOUND)

func _update_volume(property, bus) -> void:
	var current = (get_value_with_default(property, USER_SETTING_DEFAULTS[property]) -100) / 2
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), current)

func _mute_bus(property, bus) -> void:
	var enabled = get_value_with_default(property, USER_SETTING_DEFAULTS[property])
	AudioServer.set_bus_mute(AudioServer.get_bus_index(bus), not enabled)

func _configure_language() -> void:
	TranslationServer.set_locale(get_value_with_default(GAME_LANGUAGE, USER_SETTING_DEFAULTS[GAME_LANGUAGE])) 



func _configure_visuals() -> void:
	_update_resolution()
	_update_vsync()
	_update_fullscreen()

func _update_resolution() -> void:
	get_window().set_size(get_value_with_default(RESOLUTION, USER_SETTING_DEFAULTS[RESOLUTION]))

func _update_vsync() -> void:
	var enabled = get_value_with_default(VSYNC_ENABLED, USER_SETTING_DEFAULTS[VSYNC_ENABLED])
	var vysnc_status := DisplayServer.VSYNC_ENABLED if enabled else DisplayServer.VSYNC_DISABLED
	DisplayServer.window_set_vsync_mode(vysnc_status)

func _update_fullscreen() -> void:
	var enabled = get_value_with_default(FULLSCREEN_ENABLED, USER_SETTING_DEFAULTS[FULLSCREEN_ENABLED])
	var fullscreen_status := DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(fullscreen_status)
