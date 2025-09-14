extends Node2D

@export var player_scene: PackedScene
var current_level_instance: Node
var red_layer
var blue_layer
var yellow_layer
var start_layer
var end_layer
var SIZE_OFFSET = 4

func _ready() -> void:
	load_level(Globals.level)
	Globals.mode_changed.connect(_on_mode_changed)
	Globals.mode = "red"
	

func load_level(level_num: int) -> void:
	_load_level_resources(level_num)
	_set_spawn_position()
	_setup_end_triggers()

func _load_level_resources(level_num) -> void:
	var path = "res://scenes/levels/level_%d.tscn" % level_num
	var packed_scene: PackedScene = load(path)
	if not packed_scene:
		push_error("Could not load level: " + path)
		return

	# Instantiate the level
	current_level_instance = packed_scene.instantiate()
	get_tree().root.add_child(current_level_instance)

	# Get the MapLayers node
	red_layer = current_level_instance.get_node("RedLayer")
	blue_layer = current_level_instance.get_node("BlueLayer")
	yellow_layer = current_level_instance.get_node("YellowLayer")
	start_layer = current_level_instance.get_node("StartLayer")
	end_layer = current_level_instance.get_node("EndLayer")

	# Spawn the player at start tile
	if start_layer.get_used_cells().size() > 0:
		var first_cell = start_layer.get_used_cells()[0]
		var spawn_pos = start_layer.map_to_local(first_cell) + Vector2(start_layer.tile_set.tile_size) / 2
		var player_instance = player_scene.instantiate()
		player_instance.global_position = spawn_pos * 4
		get_tree().root.add_child(player_instance)

func _on_mode_changed(new_mode):
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

			# make an Area2D trigger
			var area := Area2D.new()
			var shape := CollisionShape2D.new()
			var rect := RectangleShape2D.new()
			rect.size = Vector2(end_layer.tile_set.tile_size) * SIZE_OFFSET
			shape.shape = rect
			area.add_child(shape)
			area.global_position = (pos * SIZE_OFFSET) - Vector2(32, 32)
			area.name = "EndTrigger"

			area.body_entered.connect(_on_end_trigger_entered)
			get_parent().call_deferred("add_child", area)

func _on_end_trigger_entered(body: Node) -> void:
	if body == self:
		print("Level Complete!")
		# load next level
