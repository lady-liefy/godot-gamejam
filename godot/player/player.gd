class_name Player extends CharacterBody2D

@onready var animation_tree: AnimationTree = $AnimationTree

var current_speed: float :
	get:
		current_speed = SPRINT_SPEED if is_sprinting else WALK_SPEED
		return current_speed * speed_multiplier
var input_direction: Vector2 = Vector2.ZERO
var is_sprinting: bool = false :
	set(value):
		current_speed = SPRINT_SPEED if value else WALK_SPEED
		is_sprinting = value

const WALK_SPEED: float = 120.0
const SPRINT_SPEED: float = 175.0

@export var speed_multiplier: float = 1.0

const PICKUP_RADIUS: float = 80.0
const PICKUP_SPEEDUP_RADIUS: float = 20.0
const PICKUP_DEADZONE_RADIUS: float = 6.0

# Initialization and Signals --------------------------------------------------

## Sets up signals and initializes the player.
func _ready() -> void:
	self._initialize_signals()
	self._initialize()

## Connects signals used by the player.
func _initialize_signals() -> void:
	pass

## Initializes player properties.
func _initialize() -> void:
	self.process_mode = PROCESS_MODE_PAUSABLE
	self.velocity = Vector2.ZERO
	input_direction = Vector2.ZERO

# Input Handling --------------------------------------------------------------

## Processes player inputs for movement, interaction, and sprint toggling.
func process_inputs() -> void:
	# Handle movement input
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()

	# Toggle sprinting
	if Input.is_action_just_pressed("sprint"):
		self.is_sprinting = not self.is_sprinting
#		animation_tree._animation_condition("is_sprinting", is_sprinting)

## Handles frame-based updates.
func _process(_delta: float) -> void:
	#animation_tree.update_animation_parameters()
	pass

## Handles physics-based updates, including movement.
func _physics_process(_delta: float) -> void:
	process_inputs()
	if input_direction:
		move(input_direction)
	else:
		move(Vector2.ZERO)

# Movement --------------------------------------------------------------------

## Updates the player's velocity and moves them.
func move(dir: Vector2) -> void:
	self.velocity = dir * current_speed if dir.length() != 0 else Vector2.ZERO
	move_and_slide()
