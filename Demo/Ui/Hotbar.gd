extends MarginContainer

@onready var pause_button = $HBoxContainer/Pause
@onready var play_button = $HBoxContainer/Play
@onready var species_button = $HBoxContainer/Species

signal pause
signal play
signal species_toggle

func _on_pause_pressed() -> void:
	pause.emit()
	pass # Replace with function body.

func _on_play_pressed() -> void:
	play.emit()
	pass # Replace with function body.

func _on_species_pressed() -> void:
	species_toggle.emit()
	pass # Replace with function body.
