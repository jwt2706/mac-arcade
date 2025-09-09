extends CharacterBody2D

@export var red_layer: TileMapLayer
@export var blue_layer: TileMapLayer
@export var yellow_layer: TileMapLayer

# Movement settings
@export var max_speed: float = 400.0
@export var acceleration: float = 1000.0
@export var friction: float = 800.0

# Jump & gravity settings
@export var jump_velocity: float = -400.0
@export var gravity: float = 800.0

# Power mode system
var current_mode: String = "red"

func _ready() -> void:
	set_mode("red")

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("blue"):
		set_mode("blue")
	if Input.is_action_just_pressed("red"):
		set_mode("red")
	if Input.is_action_just_pressed("yellow"):
		set_mode("yellow")

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
	
func set_mode(color) -> void:
	current_mode = color
	match color:
		"red":
			red_layer.visible = true
			blue_layer.visible = false
			yellow_layer.visible = false
		"blue":
			red_layer.visible = false
			blue_layer.visible = true
			yellow_layer.visible = false
		"yellow":
			red_layer.visible = false
			blue_layer.visible = false
			yellow_layer.visible = true
