extends CharacterBody2D

@export var speed: float = 200.0        # Horizontal movement speed
@export var jump_velocity: float = -400.0 # Negative because y+ goes down
@export var gravity: float = 1000.0     # Pixels per second squared

func _physics_process(delta: float) -> void:
	# Apply gravity if not on the floor
	if not is_on_floor():
		velocity.y += gravity * delta

	# Get input
	var direction := Input.get_axis("left", "right")

	# Horizontal movement
	velocity.x = direction * speed

	# Jump
	if Input.is_action_just_pressed("power") and is_on_floor():
		velocity.y = jump_velocity

	# Move the character
	move_and_slide()
