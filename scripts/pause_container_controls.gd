extends PanelContainer

@onready var resume_button = $PausesOptions/ResumeButton
@onready var restart_button = $PausesOptions/RestartButton
@onready var selection_button = $PausesOptions/SelectionButton
@onready var menu_button = $PausesOptions/MenuButton

var buttons: Array

func _ready() -> void:
	buttons = [resume_button, restart_button, selection_button, menu_button]
	resume_button.grab_focus()

func _process(_delta) -> void:
	if Globals.is_paused:
		if Input.is_action_just_pressed("up"):
			_move_selection(-1)
		elif Input.is_action_just_pressed("down"):
			_move_selection(1)
		elif Input.is_action_just_pressed("power"):
			# Press currently selected button
			if buttons.size() > 0:
				buttons[Globals.pause_selected_index].emit_signal("pressed")

func _move_selection(direction: int) -> void:
	Globals.pause_selected_index += direction
	
	# Wrap around
	if Globals.pause_selected_index < 0:
		Globals.pause_selected_index = buttons.size() - 1
	elif Globals.pause_selected_index >= buttons.size():
		Globals.pause_selected_index = 0
	
	_select_button(Globals.pause_selected_index)

func _select_button(index: int) -> void:
	buttons[index].grab_focus()
