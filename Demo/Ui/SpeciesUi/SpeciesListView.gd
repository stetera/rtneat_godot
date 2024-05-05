extends MarginContainer

@onready var species_rows = $Layout/SpeciesList/ScrollContainer/Rows
@onready var template = $Layout/SpeciesList/ScrollContainer/Rows/Template

@onready var species_view = preload("res://Demo/Ui/SpeciesUi/SpeciesView.tscn")

func _ready() -> void:
	$Layout/Header.set_window_name("Species List")

func refresh(alive_species: Array) -> void: # Array<Species>
	_clear_species_rows()
	
	for species: Species in alive_species:
		var entry = create_species_entry(species)
		species_rows.add_child(entry)
	
	return

func _clear_species_rows() -> void:
	var children = species_rows.get_children()
	for child: Node in children:
		if child.name == "Header" or child.name == "Template":
			continue
		child.queue_free()

func create_species_entry(species: Species) -> Node:
	var entry = template.duplicate()
	var species_label: Label = entry.get_node("Species/Value")
	var population_label: Label = entry.get_node("Population/Value")
	var fitness_label: Label = entry.get_node("Fitness/Value")
	
	species_label.text = species.species_sid
	population_label.text = str(species.species_alive_genomes.size())
	fitness_label.text = str(round(species.avg_fitness * 10)/ 10)
	
	var view_button: Button = entry.get_node("ViewButton")
	view_button.pressed.connect(_view_species.bind(species))
	
	entry.visible = true
	return entry

func _view_species(species: Species) -> void:
	var view_instance = species_view.instantiate()
	view_instance.load_species(species)
	get_parent().add_child(view_instance)

	return
