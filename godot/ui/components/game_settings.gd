class_name GameSettings
extends VBoxContainer

## Audio Settings -----------------
@onready var master_volume_toggle: CheckButton = %MasterEnabledToggle
@onready var master_volume_slider: HSlider = %MasterVolumeSlider
@onready var music_volume_toggle: CheckButton = %MusicEnabledToggle
@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var sound_volume_toggle: CheckButton = %SoundEnabledToggle
@onready var sound_volume_slider: HSlider = %SoundVolumeSlider
@onready var language_dropdown: OptionButton = %LanguageDropdown

## Visual Settings ----------------
@onready var resolution_dropdown: OptionButton = %ResolutionDropdown
@onready var full_screen_enabled_toggle: CheckButton = %FullScreenEnabledToggle
@onready var vsync_enabled_toggle: CheckButton = %VSyncEnabledToggle

## maps the index of a locale to the locale itself
var locales: PackedStringArray = PackedStringArray()

func _ready() -> void:
	_populate_locales()
	_populate_resolution_options()
	
	# Load audio toggle states from saved settings
	master_volume_toggle.set_pressed_no_signal(UserSettings.get_value("mastervolume_enabled"))
	music_volume_toggle.set_pressed_no_signal(UserSettings.get_value("musicvolume_enabled"))
	sound_volume_toggle.set_pressed_no_signal(UserSettings.get_value("soundvolume_enabled"))
	
	# Match slider editable state to toggle states
	master_volume_slider.editable = master_volume_toggle.button_pressed
	music_volume_slider.editable = music_volume_toggle.button_pressed and master_volume_toggle.button_pressed
	sound_volume_slider.editable = sound_volume_toggle.button_pressed and master_volume_toggle.button_pressed
	
	# Update slider values from settings
	master_volume_slider.value = UserSettings.get_value("mastervolume")
	music_volume_slider.value = UserSettings.get_value("musicvolume")
	sound_volume_slider.value = UserSettings.get_value("soundvolume")
	
	# Load fullscreen/vsync state from settings
	full_screen_enabled_toggle.set_pressed_no_signal(UserSettings.get_value("fullscreen_enabled"))
	vsync_enabled_toggle.set_pressed_no_signal(UserSettings.get_value("vsync_enabled"))


func _populate_locales() -> void:
	self.locales = TranslationServer.get_loaded_locales()
	if locales.is_empty():
		printerr("No locales loaded.")
		return
	
	var current_locale = TranslationServer.get_locale()
	var select_index = -1
	for i in locales.size():
		var locale = locales[i]
		var language = TranslationServer.get_locale_name(locale)
		language_dropdown.add_item(language, i)
		if current_locale == locale:
			select_index = i
	
	if select_index != -1:
		language_dropdown.select(select_index)
	else:
		printerr("Current locale not found, defaulting to index 0")
		language_dropdown.select(0)

func _populate_resolution_options() -> void:
	var resolutions = UserSettings.RESOLUTION_CHOICES
	if resolutions.is_empty():
		printerr("No resolutions available.")
		return
	
	var current_resolution: Vector2i = DisplayServer.window_get_size() 	# get_window().get_size_with_decorations()
	var select_index = -1
	for i in resolutions.size():
		var res: Vector2i = resolutions[i]
		resolution_dropdown.add_item("%dx%d" % [res.x, res.y])
		if res == current_resolution:
			select_index = i
			
	if select_index != -1:
		resolution_dropdown.select(select_index)
	else:
		printerr("Current resolution not found, defaulting to index 0")
		resolution_dropdown.select(0)


func _on_master_volume_toggle_toggled(button_pressed: bool) -> void:
	master_volume_slider.editable = button_pressed
	music_volume_slider.editable = music_volume_toggle.button_pressed and button_pressed
	sound_volume_slider.editable = sound_volume_toggle.button_pressed and button_pressed
	UserSettings.set_value("mastervolume_enabled", button_pressed)


func _on_music_enabled_toggle_toggled(button_pressed: bool) -> void:
	music_volume_slider.editable = master_volume_toggle.button_pressed and button_pressed
	UserSettings.set_value("musicvolume_enabled", button_pressed)


func _on_sound_enabled_toggle_toggled(button_pressed: bool) -> void:
	sound_volume_slider.editable = master_volume_toggle.button_pressed and button_pressed
	UserSettings.set_value("soundvolume_enabled", button_pressed)


func _on_language_dropdown_item_selected(index: int) -> void:
	UserSettings.set_value("game_locale", locales[index])


## Visuals -----------------------

func _on_resolution_dropdown_item_selected(index: int) -> void:
	# The resolution options are written in the form "XRESxYRES"
	var values := resolution_dropdown.get_item_text(index).split_floats("x")
	UserSettings.set_value("resolution", Vector2i(values[0], values[1]))

func _on_full_screen_enabled_toggle_toggled(button_pressed: bool) -> void:
	UserSettings.set_value("fullscreen_enabled", button_pressed)

func _on_v_sync_enabled_toggle_toggled(button_pressed: bool) -> void:
	UserSettings.set_value("vysnc_enabled", button_pressed)
