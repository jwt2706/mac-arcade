extends Control

func _ready() -> void:
	var highest = Globals.current_level + 1
	if (highest > Globals.highest_level):
		Globals.highest_level = highest
	
func _on_next_button_pressed() -> void:
	Globals.current_level += 1
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_replay_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
