class_name FadeOverlay
extends ColorRect

@export var default_fade_in_duration: float = 0.3
@export var default_fade_out_duration: float = 0.3
@export var default_wait_duration: float = 0.0

@onready var minimum_opacity: float = 1.0

var fade_in_duration: float = default_fade_in_duration
var fade_out_duration: float = default_fade_out_duration
var wait_duration: float = default_wait_duration

var current_tween: Tween

signal on_complete_fade_in
signal on_complete_fade_out

func _ready() -> void:
	reset_alpha(1.0)

func fade_in(duration: float = default_fade_in_duration) -> void:
	stop_fade()
	current_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var target_color: Color = Color(modulate, 0.0)
	
	fade_in_duration = duration
	
	current_tween.finished.connect(_on_complete_fade_in)
	current_tween.tween_property(self, "modulate", target_color, fade_in_duration).set_delay(0.5)

func fade_out(duration: float = default_fade_out_duration, pause_length: float = default_wait_duration) -> void:
	stop_fade()
	current_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	var target_color: Color = Color(modulate, minimum_opacity)
	
	fade_out_duration = duration
	wait_duration = pause_length
	
	current_tween.finished.connect(_on_complete_fade_out)
	current_tween.tween_property(self, "modulate", target_color, fade_out_duration).set_delay(wait_duration).from_current()

func _on_complete_fade_out() -> void:
	on_complete_fade_out.emit()
	print("FADE OUT DONE")

func _on_complete_fade_in() -> void:
	on_complete_fade_in.emit()
	print("FADE IN DONE")

func stop_fade() -> void:
	if current_tween:
		current_tween.kill()
		current_tween = null
		
	#	reset_alpha()
		reset_durations()


func reset_durations() -> void:
	fade_in_duration = default_fade_in_duration
	fade_out_duration = default_fade_out_duration
	wait_duration = default_wait_duration

func reset_alpha(new_a: float) -> void:
	modulate.a = clampf(modulate.a, minimum_opacity, new_a) if visible else 1.0
