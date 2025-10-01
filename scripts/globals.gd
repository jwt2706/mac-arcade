extends Node

signal mode_changed(new_mode)

var mode : String:
	set(new_mode):
		if mode != new_mode:
			mode = new_mode
			mode_changed.emit(mode)

var is_paused = false
var pause_selected_index = 0

var total_levels = 5
var current_level = 1
var highest_level = 1
