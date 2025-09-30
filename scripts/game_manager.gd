extends Node2D

@export var player_scene: PackedScene
@export var SIZE_OFFSET := 4
@export var START_DELAY: float = 1.0

var current_level_instance: Node
var red_layer
var blue_layer
var yellow_layer
var start_layer
var end_layer
var spike_layer

var can_play: bool = false

@onready var pause_container = $PauseContainer
@onready var level_container = $LevelContainer

# -------------------------
# LIFE CYCLE
# -------------------------
func _ready() -> void:
	Globals.mode_changed.connect(_on_mode_changed)
	pause_container.visible = false

	load_level(Globals.current_level)
	
	# Show full map for 1 second, then switch to red layer
	can_play = false
	await get_tree().create_timer(1.0).timeout
	Globals.mode = "red"
	can_play = true

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("select"):
		toggle_pause()

# -------------------------
# PAUSE
# -------------------------
func toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	pause_container.visible = get_tree().paused

# -------------------------
# LEVEL MANAGEMENT
# -------------------------
func load_level(level_num: int) -> void:
	_clear_current_level()

	var path := "res://scenes/levels/level_%d.tscn" % level_num
	var packed_scene: PackedScene = load(path)
	if not packed_scene:
		push_error("Could not load level: " + path)
		return

	# Instantiate level
	current_level_instance = packed_scene.instantiate()
	current_level_instance.scale = Vector2(SIZE_OFFSET, SIZE_OFFSET)
	level_container.add_child(current_level_instance)

	# Cache layers
	red_layer = current_level_instance.get_node("RedLayer")
	blue_layer = current_level_instance.get_node("BlueLayer")
	yellow_layer = current_level_instance.get_node("YellowLayer")
	start_layer = current_level_instance.get_node("StartLayer")
	end_layer = current_level_instance.get_node("EndLayer")
	spike_layer = current_level_instance.get_node("SpikeLayer")

	# Spawn player
	_spawn_player()
	_setup_end_triggers()
	_setup_spike_triggers()

	# --- START PREVIEW LOGIC ---
	can_play = false
	await get_tree().create_timer(START_DELAY).timeout
	Globals.mode = "red"
	can_play = true

func reload_level() -> void:
	load_level(Globals.current_level)

func _clear_current_level() -> void:
	if current_level_instance and current_level_instance.is_inside_tree():
		current_level_instance.queue_free()
		current_level_instance = null

	# Clear leftover nodes
	for child in level_container.get_children():
		child.queue_free()

# -------------------------
# PLAYER
# -------------------------
func _spawn_player() -> void:
	if start_layer and start_layer.get_used_cells().size() > 0:
		var first_cell = start_layer.get_used_cells()[0]
		var spawn_pos = start_layer.map_to_local(first_cell) * SIZE_OFFSET
		var player_instance = player_scene.instantiate()
		player_instance.global_position = spawn_pos
		player_instance.can_move = false
		level_container.add_child(player_instance)

		# Enable movement after preview
		_defer_enable_player(player_instance)

func _defer_enable_player(player_instance: Node) -> void:
	await get_tree().create_timer(START_DELAY).timeout
	player_instance.can_move = true

# -------------------------
# TRIGGERS
# -------------------------
func _setup_end_triggers() -> void:
	if not end_layer:
		return

	for cell in end_layer.get_used_cells():
		var pos: Vector2 = end_layer.map_to_local(cell) + Vector2(end_layer.tile_set.tile_size) / 2.0
		var area := Area2D.new()
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(end_layer.tile_set.tile_size) * SIZE_OFFSET
		shape.shape = rect
		area.add_child(shape)
		area.global_position = (pos * SIZE_OFFSET) - Vector2(32, 32)
		area.name = "EndTrigger"

		level_container.add_child(area)  # Add first
		area.body_entered.connect(_on_end_trigger_entered)  # Connect after

func _setup_spike_triggers() -> void:
	if not spike_layer:
		return

	for cell in spike_layer.get_used_cells():
		var pos: Vector2 = spike_layer.map_to_local(cell) + Vector2(spike_layer.tile_set.tile_size) / 2.0
		var area := Area2D.new()
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(spike_layer.tile_set.tile_size) * SIZE_OFFSET
		shape.shape = rect
		area.add_child(shape)
		area.global_position = (pos * SIZE_OFFSET) - Vector2(32, 32)
		area.name = "SpikeTrigger"

		level_container.add_child(area)  # Add first
		area.body_entered.connect(_on_spike_trigger_entered)  # Connect after

# -------------------------
# MODE SWITCHING
# -------------------------
func _on_mode_changed(new_mode: String) -> void:
	if not red_layer or not blue_layer or not yellow_layer:
		return

	match new_mode:
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

# -------------------------
# TRIGGER CALLBACKS
# -------------------------
func _on_end_trigger_entered(body: Node) -> void:
	if not can_play:
		return
	if body.name == "Player":
		call_deferred("_go_to_level_end")

func _on_spike_trigger_entered(body: Node) -> void:
	if not can_play:
		return
	if body.name == "Player":
		call_deferred("reload_level")

func _go_to_level_end() -> void:
	get_tree().change_scene_to_file("res://scenes/level_end.tscn")

# -------------------------
# UI BUTTONS
# -------------------------
func _on_resume_button_pressed() -> void:
	toggle_pause()

func _on_restart_button_pressed() -> void:
	pause_container.visible = false
	get_tree().paused = false
	call_deferred("reload_level")

func _on_selection_button_pressed() -> void:
	toggle_pause()
	get_tree().change_scene_to_file("res://scenes/level_selection.tscn")

func _on_menu_button_pressed() -> void:
	toggle_pause()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
