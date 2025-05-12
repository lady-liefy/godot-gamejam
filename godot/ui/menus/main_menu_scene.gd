class_name MainMenu_Scene
extends Control

@onready var continue_button: Button = %ContinueButton
@onready var new_game_button: Button = %NewGameButton
@onready var settings_button: Button = %SettingsButton
@onready var exit_button: Button = %ExitButton

@onready var world: World = Global.world
@onready var fade_overlay: FadeOverlay = world.fade_overlay
@onready var next_path: PackedScene
@onready var input_blocker: Control = %InputBlocker

func _ready() -> void:
	input_blocker.visible = true
	new_game_button.disabled = Global.game_path == null
	settings_button.disabled = Global.settings_path == null
	continue_button.visible = SaveGame.has_save() and SaveGame.ENABLED
	
	# connect signals
	new_game_button.pressed.connect(_on_play_button_pressed)
	continue_button.pressed.connect(_on_continue_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)

func _on_settings_button_pressed() -> void:
	next_path = Global.settings_path
	input_blocker.visible = true
	fade_overlay.on_complete_fade_out.connect(_on_fade_out_done, ConnectFlags.CONNECT_ONE_SHOT)
	fade_overlay.fade_out()

func _on_play_button_pressed() -> void:
	world.new_game = true
	next_path = Global.game_path
	world.menu_music.stop()
	
	if world.new_game and SaveGame.has_save():
		print_debug("deleting savefile for new game")
		SaveGame.delete_save()
	
	input_blocker.visible = true
	fade_overlay.on_complete_fade_out.connect(_on_fade_out_done, ConnectFlags.CONNECT_ONE_SHOT)
	fade_overlay.fade_out()

func _on_continue_button_pressed() -> void:
	world.new_game = false
	next_path = Global.game_path
	world.menu_music.stop()
	input_blocker.visible = true
	fade_overlay.on_complete_fade_out.connect(_on_fade_out_done, ConnectFlags.CONNECT_ONE_SHOT)
	fade_overlay.fade_out()

func _on_exit_button_pressed() -> void:
	input_blocker.visible = true
	fade_overlay.fade_out()
	fade_overlay.on_complete_fade_out.connect(get_tree().quit, ConnectFlags.CONNECT_ONE_SHOT)

func allow_input(allow: bool = true) -> void:
	input_blocker.visible = not allow
	
	if not allow:
		return
	
	if continue_button.visible:
		continue_button.grab_focus()
	else:
		new_game_button.grab_focus()

func _on_fade_out_done():
	world._clear_menu_scene(self, _to_next_scene())

func _to_next_scene():
	if not next_path or not (next_path is PackedScene):
		push_error("next_path is invalid or not a PackedScene!")
		return null
	
	return next_path.instantiate()
