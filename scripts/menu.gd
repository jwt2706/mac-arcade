extends Control

@onready var menu_options = $MenuOptions
@onready var settings_panel = $SettingsPanel
@onready var settings_options = $SettingsPanel/SettingsOptions

var buttons: Array
var current_index := 0

func _ready() -> void:
	settings_panel.visible = false
	buttons = menu_options.get_children()
	_update_focus()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("up"):
		current_index = (current_index - 1) % buttons.size()
		_update_focus()
	elif event.is_action_pressed("down"):
		current_index = (current_index + 1) % buttons.size()
		_update_focus()
	elif event.is_action_pressed("select"):
		buttons[current_index].emit_signal("pressed")

func _update_focus() -> void:
	buttons[current_index].grab_focus()

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_start_random_button_pressed() -> void:
	pass # Replace with function body.

func _on_settings_button_pressed() -> void:
	settings_panel.visible = true
	buttons = settings_options.get_children()
	_update_focus()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_return_button_pressed() -> void:
	settings_panel.visible = false
	buttons = menu_options.get_children()
	_update_focus()
