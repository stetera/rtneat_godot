extends MarginContainer

@onready var id = $Layout/GenomeInfo/TabNameContainer/GridContainer/Id
@onready var age = $Layout/GenomeInfo/TabNameContainer/GridContainer/Age
@onready var pop = $Layout/GenomeInfo/TabNameContainer/GridContainer/Pop
@onready var avg_fit = $Layout/GenomeInfo/TabNameContainer/GridContainer/AvgFitness
@onready var best_fit = $Layout/GenomeInfo/TabNameContainer/GridContainer/BestFitness

@onready var genome_rows = $Layout/GenomeList/ScrollContainer/Rows
@onready var template = $Layout/GenomeList/ScrollContainer/Rows/Template

@onready var genome_view = preload("res://Demo/Ui/GenomeUi/GenomeView.tscn")


var species: Species = null

func _ready() -> void:
	id.text = "Id: " + species.species_sid
	age.text = "Evaluations: " + str(species.age)
	pop.text = "Population: " + str(species.species_alive_genomes.size())
	avg_fit.text = "Avg fitness: " + str(round(species.avg_fitness * 100)/ 100)
	best_fit.text = "Best fitness: " + str(round(species.best_ever_fitness * 100) / 100)
	
	_populate_rows()


func load_species(species_data: Species) -> void:
	$Layout/Header.set_window_name("Species: " + species_data.species_sid)
	species = species_data


func _populate_rows() -> void:
	_clear_genome_rows()
	
	for genome: Genome in species.species_alive_genomes:
		var entry: Node = create_species_entry(genome)
		genome_rows.add_child(entry)

func create_species_entry(genome: Genome) -> Node:
	var entry = template.duplicate()
	var genome_label: Label = entry.get_node("Columns/Genome/Value")
	var fitness_label: Label = entry.get_node("Columns/Fitness/Value")
	
	
	genome_label.text = str(genome.genome_id)
	fitness_label.text = str(round(genome.fitness * 100) / 100)
	
	var view_button: Button = entry.get_node("ViewButton")
	view_button.pressed.connect(_view_genome.bind(genome))
	
	entry.visible = true
	return entry

func _view_genome(genome: Genome) -> void:
	var genome_view_instance = genome_view.instantiate()
	genome_view_instance.load_genome(genome)
	
	get_parent().add_child(genome_view_instance)

	return


func _clear_genome_rows() -> void:
	var children = genome_rows.get_children()
	for child: Node in children:
		if child.name == "Header" or child.name == "Template":
			continue
		child.queue_free()
