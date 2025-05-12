class_name World
extends Node

@onready var ui: CanvasLayer = $UI
@onready var menus: CanvasLayer = $Menus

@onready var fade_overlay: FadeOverlay = %FadeOverlay
@onready var pause_overlay: PauseOverlay = %PauseOverlay

var is_transitioning: bool = false
var bootsplash_scene: BootsplashScene

@onready var new_game: bool = true

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	self._init_signals()
	
	Global.world = self
	Global.fade_overlay = fade_overlay
	Global.pause_overlay = pause_overlay
	
	bootsplash_scene = Global.bootsplash_path.instantiate()
	menus.add_child(bootsplash_scene)
	bootsplash_scene.owner = menus
	
	fade_overlay.visible = true

func _init_signals() -> void:
	pause_overlay.game_exited.connect(_save_game)

func _process(_delta : float) -> void:
	if is_transitioning:
		set_process_input(false)
		return

func _clear_menu_scene(old_scene, new_scene) -> void:
	is_transitioning = true
	
	menus.add_child(new_scene)
	new_scene.owner = menus
	old_scene.call_deferred("queue_free")
	
	fade_overlay.reset_durations()
	
	for connection in fade_overlay.on_complete_fade_in.get_connections():
		fade_overlay.on_complete_fade_in.disconnect(connection.callable)
	for connection in fade_overlay.on_complete_fade_out.get_connections():
		fade_overlay.on_complete_fade_out.disconnect(connection.callable)
	
	fade_overlay.on_complete_fade_in.connect(
		func():
			set_process_input(true)
			new_scene.allow_input(true)
			is_transitioning = false
	)
	
	fade_overlay.reset_alpha(1.0)
	fade_overlay.fade_in()

func _save_game() -> void:
	SaveGame.save_game(get_tree())


@onready var menu_music: AudioStreamPlayer = $Menus/Music

func _on_menus_child_entered_tree(node: Node) -> void:
	if node is AudioStreamPlayer or node is BootsplashScene:
		return
	if not menu_music.playing:
		menu_music.play()
