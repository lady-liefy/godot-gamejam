class_name GameSettings_Scene
extends Control

@export var stay_duration: float = 0.0

@onready var return_button: Button = %ReturnButton

@onready var world: World = Global.world
@onready var fade_overlay: FadeOverlay = world.fade_overlay
@onready var next_path: PackedScene = Global.menu_path
@onready var input_blocker: Control = %InputBlocker

func _ready():
	input_blocker.visible = true

func _on_return_button_pressed():
	fade_overlay.on_complete_fade_out.connect(_on_fade_out_done, ConnectFlags.CONNECT_ONE_SHOT)
	fade_overlay.fade_out()

func allow_input(allow: bool = true) -> void:
	input_blocker.visible = not allow
	
	if not allow:
		return
	
	return_button.grab_focus()

func _to_next_scene():
	if not next_path or not (next_path is PackedScene):
		push_error("next_path is invalid or not a PackedScene!")
		return null
	
	return next_path.instantiate()

func _on_fade_out_done():
	world._clear_menu_scene(self, _to_next_scene())

func _on_apply_button_pressed() -> void:
	next_path = Global.settings_path
	world._clear_menu_scene(self, _to_next_scene())
