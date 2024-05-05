extends Node

@onready var hotbar_reference = preload("res://Demo/Ui/Hotbar.tscn")
var hotbar: Node

@onready var species_list_view_reference = preload("res://Demo/Ui/SpeciesUi/SpeciesListView.tscn")
var species_list_view: Node
var species_visible = false

var ui_parent: Node = null

signal play
signal pause
signal species_toggle

func refresh_species(species: Array) -> void: # Array<Species>
	if species_list_view and is_instance_valid(species_list_view):
		species_list_view.refresh(species)

func node_to_top_level(node: Node) -> void:
	move_child(node, get_child_count() - 1)

func start_hotbar(parent: CanvasLayer) -> void:
	ui_parent = parent
	
	hotbar = hotbar_reference.instantiate()
	parent.add_child(hotbar)
	
	hotbar.play.connect(_on_play)
	hotbar.pause.connect(_on_pause)
	hotbar.species_toggle.connect(_on_species_toggle)


func _on_play() -> void:
	play.emit()

func _on_pause() -> void:
	pause.emit()

func _on_species_toggle() -> void:
	if species_list_view and is_instance_valid(species_list_view):
		species_list_view.queue_free()
		species_list_view = null
	else:
		start_species_list()

func start_species_list() -> void:
	species_list_view = species_list_view_reference.instantiate()
	ui_parent.add_child(species_list_view)
