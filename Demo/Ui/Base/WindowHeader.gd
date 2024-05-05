extends MarginContainer

"""The basic window script that is used by all window scenes. Allows for dragging
and closing windows. Is connected to the NeatGUI Node to allow focussing the current
window.
"""

signal focus_window

var drag_position = null

func set_window_name(name: String) -> void:
	$HeaderColumns/TabNameContainer/TabName.text = name

func _on_focus_entered() -> void:
	UiController.node_to_top_level(self)

func _on_close_button_button_down() -> void:
	get_parent().get_parent().queue_free()


func _on_gui_input(event: InputEvent) -> void:
	"""Drag the window if the Decorator is clicked.
	"""
	if event is InputEventMouseButton and event.button_index == 1:
		if event.pressed:
			# start dragging
			drag_position = get_global_mouse_position() - global_position
			emit_signal("focus_window", owner)
		else:
			# end dragging
			drag_position = null
	# now update the window pos accordingly
	if event is InputEventMouseMotion and drag_position:
		owner.global_position = get_global_mouse_position() - drag_position
