extends CharacterBody2D

# Movement settings
@export var max_speed: float = 400.0
@export var acceleration: float = 1000.0
@export var friction: float = 800.0

# Jump & gravity settings
@export var jump_velocity: float = -400.0
@export var gravity: float = 800.0

# Power mode system
var current_mode: String = "red"

func _physics_process(delta: float) -> void:
	# --- Mode switching ---
	if Input.is_action_just_pressed("blue"):
		current_mode = "blue"
	if Input.is_action_just_pressed("red"):
		current_mode = "red"
	if Input.is_action_just_pressed("yellow"):
		current_mode = "yellow"

	velocity.y += gravity * delta
	var direction := Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	# --- Power mode actions ---
	if Input.is_action_just_pressed("power"):
		match current_mode:
			"blue": # flip gravity
				gravity = -gravity
				jump_velocity = -jump_velocity
			"yellow": # leave afterimage
				pass
			"red": # whip
				pass

	move_and_slide()
