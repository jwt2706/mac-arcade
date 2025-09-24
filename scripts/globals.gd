extends Node

signal mode_changed(new_mode)

var mode : String:
	set(new_mode):
		if mode != new_mode:
			mode = new_mode
			mode_changed.emit(mode)

var total_levels = 12
var current_level = 1
var highest_level = 1
