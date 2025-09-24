extends Control

@export var columns: int = 6

func _ready():
	var grid = $LevelsContainer
	grid.columns = columns

	for i in range(Globals.total_levels):
		var button: Button
		button = Button.new()
		
		button.text = str(i + 1)
		button.name = "Level_%d" % (i + 1)
		button.custom_minimum_size = Vector2(250, 250)  # width, height
		button.add_theme_font_size_override("font_size", 64)
		if (Globals.highest_level > i):
			button.disabled = false
		else:
			button.disabled = true

		# connect signal so clicking loads that level
		button.pressed.connect(func():
			_on_level_button_pressed(i + 1)
		)

		grid.add_child(button)

func _on_level_button_pressed(level_num: int) -> void:
	print("Loading Level", level_num)
	Globals.current_level = level_num
	get_tree().change_scene_to_file("res://scenes/game.tscn")
