extends CharacterBody2D

@export var whip_hitbox: Area2D
@export var red_layer: TileMapLayer
@export var blue_layer: TileMapLayer
@export var yellow_layer: TileMapLayer
@export var start_layer: TileMapLayer
@export var end_layer: TileMapLayer
@export var after_image_scene: PackedScene = preload("res://scenes/after_image.tscn")

@export var attack_length: float = 0.2

@export var max_speed: float = 400.0
@export var acceleration: float = 1000.0
@export var friction: float = 800.0
@export var jump_velocity: float = -400.0
@export var gravity: float = 800.0

var current_mode: String = "red"
var attacking: bool = false

var SIZE_OFFSET = 4

func _ready() -> void:
	set_mode("red")
	_set_spawn_position()
	_setup_end_triggers()

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
		whip_hitbox.scale.x = 1 if direction > 0 else -1
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	if Input.is_action_just_pressed("power"):
		match current_mode:
			"blue":
				flip_gravity()
			"yellow":
				spawn_after_image()
			"red":
				attack_whip()
	move_and_slide()

func _set_spawn_position() -> void:
	if start_layer:
		var cells = start_layer.get_used_cells()
		if cells.size() > 0:
			var spawn_pos = start_layer.map_to_local(cells[0])
			global_position = spawn_pos * SIZE_OFFSET

func _setup_end_triggers() -> void:
	if end_layer:
		for cell in end_layer.get_used_cells():
			var pos = end_layer.map_to_local(cell) + Vector2(end_layer.tile_set.tile_size) / 2.0

			# Make an Area2D trigger
			var area := Area2D.new()
			var shape := CollisionShape2D.new()
			var rect := RectangleShape2D.new()
			rect.size = Vector2(end_layer.tile_set.tile_size) * SIZE_OFFSET
			shape.shape = rect
			area.add_child(shape)
			area.global_position = (pos * SIZE_OFFSET) - Vector2(32, 32)
			area.name = "EndTrigger"

			# Connect signal
			area.body_entered.connect(_on_end_trigger_entered)

			# Defer the add_child to avoid "busy setting up children" error
			get_parent().call_deferred("add_child", area)

func _on_end_trigger_entered(body: Node) -> void:
	if body == self:
		print("Level Complete!")

func set_mode(color: String) -> void:
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

func flip_gravity() -> void:
	gravity = -gravity
	jump_velocity = -jump_velocity

func spawn_after_image() -> void:
	if after_image_scene:
		var after_image = after_image_scene.instantiate()
		after_image.global_position = global_position
		get_parent().add_child(after_image)

func attack_whip() -> void:
	if attacking:
		return # prevent spam
	
	attacking = true
	print("attacking")
	whip_hitbox.monitoring = true
	
	await get_tree().create_timer(attack_length).timeout
	whip_hitbox.monitoring = false
	attacking = false
	print("done attacking")
	
	# ENEMIES EXAMPLE CODE OR SMTH:
	#func _on_WhipHitbox_body_entered(body: Node) -> void:
	#if body.is_in_group("enemies"):
	#	body.take_damage(1)  # assuming your enemies have this method
