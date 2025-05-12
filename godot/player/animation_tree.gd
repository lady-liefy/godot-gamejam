extends AnimationTree

@onready var player: Player = $".."
@onready var state_machine: AnimationNodeStateMachinePlayback = get("parameters/playback")


func _ready() -> void:
	active = true
	_animation_condition("idle", true)

## Updates parameters for animations.
func update_animation_parameters() -> void:
	var is_moving: bool = (player.velocity == Vector2.ZERO)
	_animation_condition("idle", is_moving)
	_animation_condition("is_moving", not is_moving)
	if player.input_direction != Vector2.ZERO:
		_animation_playback("Walk", player.input_direction)
		_animation_playback("Idle", player.input_direction)
		_animation_playback("Sprint", player.input_direction)

## Handles animation transitions.
func _animation_playback(State: StringName, dir: Vector2) -> void:
	state_machine.travel("{State}".format({"State": State}))
	set("parameters/{State}/blend_position".format({"State": State}), dir)

## Sets animation conditions.
func _animation_condition(Condition: StringName, value: bool) -> void:
	set("parameters/conditions/{Condition}".format({"Condition": Condition}), value)
