
extends Camera2D

## A simple 2D camera that can pan with right click and zoom using mouse scroll.

const ZOOM_SPEED = Vector2(0.2, 0.2)
const MIN_ZOOM = .3
const MAX_ZOOM = 1

@onready var target_zoom = zoom
@onready var wanted_position = position
var dragging = false

func _unhandled_input(event):
	if event is InputEventMouseButton:

		match event.button_index:
			MOUSE_BUTTON_RIGHT: # Right button
				dragging = true
				if dragging and not event.pressed:
					dragging = false
					
			MOUSE_BUTTON_WHEEL_UP: # Scroll wheel up
				target_zoom -= ZOOM_SPEED

				if target_zoom.x > MIN_ZOOM:

					wanted_position = wanted_position.lerp(get_global_mouse_position(), -0.1)
				
			MOUSE_BUTTON_WHEEL_DOWN: # Scroll wheel down
				target_zoom += ZOOM_SPEED
				if target_zoom.x < MAX_ZOOM:

					wanted_position = wanted_position.lerp(get_global_mouse_position(), 0.3)
			_:
				pass
		
		# Clamp the zoom so it doesn't go below MIN_ZOOM or above MAX_ZOOM
		target_zoom = Vector2(clamp(target_zoom.x, MIN_ZOOM, MAX_ZOOM), clamp(target_zoom.y, MIN_ZOOM, MAX_ZOOM))
	
	if event is InputEventMouseMotion and dragging:
		wanted_position -= (event.relative*zoom * 4)

func _process(delta):
	# Move/Zoom the camera smoothly
	zoom = zoom.lerp(target_zoom, 4*delta)
	position = position.lerp(wanted_position, 5*delta)


func set_focus(focus_position: Vector2) -> void:
	wanted_position = focus_position

"""
onready var camera = get_node("Camera2D")

# Settings

## Movement
var cameraBeingDragged = false
var dragFactor: Vector2

const DRAG_FACTOR_CUTOFF = 4
const MOVEMENT_TIMEOUT = 0.3
var lastMoveTime = 0

## Zoom
var ZOOM_SPEED = 200
var ZOOM_MARGIN = 0.3
var ZOOM_MIN = 0.2
var ZOOM_MAX = 10

## Zoom variables
var zoompos = Vector2()
var zoomfactor = 5.0

var lastStepTime = 0
const STEP_TIMEOUT = 0.1
var zoomstep = 0.5


func _process(delta: float):
	zoom.x = lerp(zoom.x, zoom.x * zoomfactor, ZOOM_SPEED * delta)
	zoom.y = lerp(zoom.y, zoom.y * zoomfactor, ZOOM_SPEED * delta)
	
	zoom.x = clamp(zoom.x, ZOOM_MIN, ZOOM_MAX)
	zoom.y = clamp(zoom.y, ZOOM_MIN, ZOOM_MAX)
	
	if lastStepTime < STEP_TIMEOUT:
		lastStepTime += delta
	else:
		zoomfactor = 1.0
		
		
	if Input.is_action_just_pressed("mouse_primary"):
		cameraBeingDragged = true
		
	if cameraBeingDragged: 
		lastMoveTime += delta
		
		if lastMoveTime > MOVEMENT_TIMEOUT and dragFactor.length() < DRAG_FACTOR_CUTOFF:
			dragFactor = Vector2.ZERO
			
		position += dragFactor
	
	
func _input(event: InputEvent):
	if abs(zoompos.x - get_global_mouse_position().x) > ZOOM_MARGIN:
		zoomfactor = 1.0
	if abs(zoompos.y - get_global_mouse_position().y) > ZOOM_MARGIN:
		zoomfactor = 1.0
		
	if event is InputEventMouseButton:
		_reposition_and_zoom(event)
	
	if event is InputEventMouseMotion:
		_set_dragging(event)
		
		
func _set_dragging(event: InputEvent):

	if Input.is_action_pressed("mouse_primary"):
		dragFactor = -event.relative
	else:
		cameraBeingDragged = false
		dragFactor = Vector2.ZERO
	
	
		
func _reposition_and_zoom(event: InputEvent):
		lastStepTime = 0
		var scroll_in_factor = event.get_action_strength("scroll_in")
		var scroll_out_factor = event.get_action_strength("scroll_out")
	
		zoomfactor += scroll_in_factor * -0.01 + scroll_out_factor * 0.01
		zoompos = get_global_mouse_position()
"""
