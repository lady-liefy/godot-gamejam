class_name BootsplashScene
extends Control

@export var stay_duration: float = 1.0
@export var fade_in_duration: float = 1.5
@export var interuptable: bool = true

@onready var world: World = Global.world
@onready var fade_overlay: FadeOverlay = world.fade_overlay
@onready var next_path: PackedScene = Global.menu_path

func _ready() -> void:
	fade_overlay.on_complete_fade_out.connect(_on_fade_out_done, ConnectFlags.CONNECT_ONE_SHOT)
	fade_overlay.on_complete_fade_in.connect(fade_overlay.fade_out.bind(0.8, stay_duration), ConnectFlags.CONNECT_ONE_SHOT)
	
	fade_overlay.fade_in(fade_in_duration)

func _input(event: InputEvent) -> void:
	if world.is_transitioning:
		return
	
	if event.is_action_pressed("interact") or event.is_action_pressed("cancel"):
		if interuptable:
			get_viewport().set_input_as_handled()
			
			world.fade_overlay.stop_fade()
			_on_fade_out_done()

func _to_next_scene():
	if not next_path or not (next_path is PackedScene):
		push_error("next_path is invalid or not a PackedScene!")
		return null
	return next_path.instantiate()

func _on_fade_out_done():
	world._clear_menu_scene(self, _to_next_scene())
#	fade_overlay.fade_in()
