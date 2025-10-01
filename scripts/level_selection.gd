extends Control

@export var columns: int = 6

var selected_index: int = 0
var buttons: Array = []

func _ready():
	var grid = $LevelsContainer
	grid.columns = columns

	# Create buttons
	for i in range(Globals.total_levels):
		var button = Button.new()
		button.text = str(i + 1)
		button.name = "Level_%d" % (i + 1)
		button.custom_minimum_size = Vector2(250, 250)
		button.add_theme_font_size_override("font_size", 64)
		button.disabled = i >= Globals.highest_level
		button.pressed.connect(func(level=i + 1):
			_on_level_button_pressed(level)
		)
		grid.add_child(button)
		buttons.append(button)

	# Initially focus the first enabled button
	_select_button(selected_index)
	set_process(true)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("right"):
		_move_selection(1, 0)
	elif Input.is_action_just_pressed("left"):
		_move_selection(-1, 0)
	elif Input.is_action_just_pressed("down"):
		_move_selection(0, 1)
	elif Input.is_action_just_pressed("up"):
		_move_selection(0, -1)
	elif Input.is_action_just_pressed("power"):
		# Press currently selected button
		if buttons.size() > 0:
			var btn = buttons[selected_index]
			if not btn.disabled:
				btn.emit_signal("pressed")

# -------------------------
# Navigation helpers
# -------------------------
func _move_selection(x_offset: int, y_offset: int) -> void:
	var total = buttons.size()
	if total == 0:
		return
	
	var row = selected_index / columns
	var col = selected_index % columns
	
	row += y_offset
	col += x_offset
	
	# Clamp row and column
	row = clamp(row, 0, ceil(total / columns) - 1)
	col = clamp(col, 0, columns - 1)
	
	var new_index = row * columns + col
	# Clamp within array bounds
	new_index = clamp(new_index, 0, total - 1)
	
	# Skip disabled buttons
	while buttons[new_index].disabled:
		if x_offset != 0:
			new_index += x_offset
		elif y_offset != 0:
			new_index += y_offset * columns
		else:
			new_index += 1

		if new_index < 0:
			new_index = total - 1
		elif new_index >= total:
			new_index = 0
	
	selected_index = new_index
	_select_button(selected_index)

func _select_button(index: int) -> void:
	if buttons.size() == 0:
		return
	buttons[index].grab_focus()

# -------------------------
# Button callback
# -------------------------
func _on_level_button_pressed(level_num: int) -> void:
	Globals.current_level = level_num
	get_tree().change_scene_to_file("res://scenes/game.tscn")
