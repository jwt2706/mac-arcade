extends Control

@onready var buttons: Array = [
	$MenuOptions/ReplayButton,
	$MenuOptions/MenuButton
]

var selected_index: int = 0

func _ready() -> void:
	# Focus first button initially
	_select_button(selected_index)
	set_process(true)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("up"):
		_move_selection(-1)
	elif Input.is_action_just_pressed("down"):
		_move_selection(1)
	elif Input.is_action_just_pressed("power"):
		# Press currently selected button
		buttons[selected_index].emit_signal("pressed")

# -------------------------
# Navigation helpers
# -------------------------
func _move_selection(direction: int) -> void:
	selected_index += direction
	
	# Wrap around
	if selected_index < 0:
		selected_index = buttons.size() - 1
	elif selected_index >= buttons.size():
		selected_index = 0
	
	_select_button(selected_index)

func _select_button(index: int) -> void:
	buttons[index].grab_focus()

# -------------------------
# Button callbacks
# -------------------------
func _on_replay_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
