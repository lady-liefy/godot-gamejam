class_name InGame_Scene
extends Node2D

@export var stay_duration: float = 0.0

@onready var world: World = Global.world
@onready var fade_overlay: FadeOverlay = Global.fade_overlay
@onready var pause_overlay: PauseOverlay = Global.pause_overlay

@onready var next_path: PackedScene = Global.menu_path
@onready var input_blocker: Control = %InputBlocker

func _ready() -> void:
	fade_overlay.visible = true
	
	if SaveGame.has_save():
		SaveGame.load_game(get_tree())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not pause_overlay.visible:
		get_viewport().set_input_as_handled()
		get_tree().paused = true
		pause_overlay.grab_button_focus()
		pause_overlay.visible = true

func allow_input(allow: bool = true) -> void:
	input_blocker.visible = not allow
	
	if not allow:
		return

func _to_next_scene():
	return next_path.instantiate()
