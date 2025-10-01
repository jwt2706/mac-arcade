extends CharacterBody2D

@export var whip_hitbox: Area2D
@export var animated_sprite: AnimatedSprite2D
var after_image_scene: PackedScene = preload("res://scenes/after_image.tscn")

@export var attack_length: float = 0.2
@export var max_speed: float = 400.0
@export var acceleration: float = 1000.0
@export var friction: float = 1200.0
@export var gravity: float = 800.0

var attacking: bool = false
var can_move: bool = true

func _ready() -> void:
	whip_hitbox.area_entered.connect(_on_whip_hitbox_area_entered)

func _physics_process(delta: float) -> void:
	if not can_move:
		return
	
	# MODE SWITCHING
	if Input.is_action_just_pressed("red"):
		Globals.mode = "red"
	if Input.is_action_just_pressed("blue"):
		Globals.mode = "blue"
	if Input.is_action_just_pressed("yellow"):
		Globals.mode = "yellow"

	velocity.y += gravity * delta
	var direction := Input.get_axis("left", "right")

	# MOVEMENT + FLIPPING
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)

		var facing_right = direction > 0
		whip_hitbox.scale.x = 1 if facing_right else -1
		animated_sprite.flip_h = not facing_right
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	# ANIMATIONS
	var prefix := Globals.mode  # "red", "blue", or "yellow"
	if direction != 0:
		var run_anim := prefix + "_run"
		if animated_sprite.animation != run_anim or not animated_sprite.is_playing():
			if animated_sprite.sprite_frames.has_animation(run_anim):
				animated_sprite.play(run_anim)
	else:
		var idle_anim := prefix + "_idle"
		if animated_sprite.animation != idle_anim or not animated_sprite.is_playing():
			if animated_sprite.sprite_frames.has_animation(idle_anim):
				animated_sprite.play(idle_anim)

	# POWER ABILITIES
	if Input.is_action_just_pressed("power"):
		match Globals.mode:
			"red":
				attack_whip()
			"blue":
				flip_gravity()
			"yellow":
				spawn_after_image()

	move_and_slide()

func flip_gravity() -> void:
	gravity = -gravity
	animated_sprite.flip_v = gravity < 0

func spawn_after_image() -> void:
	if after_image_scene:
		var after_image = after_image_scene.instantiate()
		after_image.global_position = global_position
		get_parent().add_child(after_image)

func attack_whip() -> void:
	if attacking:
		return
	
	attacking = true
	whip_hitbox.monitoring = true
	
	await get_tree().create_timer(attack_length).timeout
	whip_hitbox.monitoring = false
	attacking = false

var spike_break_fx = preload("res://scenes/fx/break_spike_fx.tscn")

func _on_whip_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("spikes"):
		# Remove the tile
		if area.has_meta("cell"):
			var cell: Vector2i = area.get_meta("cell")
			var gm = get_tree().get_first_node_in_group("game_manager")
			if gm and gm.spike_layer:
				gm.spike_layer.set_cell(cell, -1)

		# ✨ Spawn particle effect
		var fx: GPUParticles2D = spike_break_fx.instantiate()
		fx.global_position = area.global_position
		area.queue_free()
		get_tree().current_scene.add_child(fx)
		fx.emitting = true

		# Remove it after its lifetime
		await get_tree().create_timer(fx.lifetime + 0.1).timeout
		fx.queue_free()
