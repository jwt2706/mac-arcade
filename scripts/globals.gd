extends Node

signal mode_changed(new_mode)

var mode : String:
	set(new_mode):
		if mode != new_mode:
			mode = new_mode
			mode_changed.emit(mode)

var level = 1
