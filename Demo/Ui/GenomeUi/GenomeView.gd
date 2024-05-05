extends MarginContainer

@onready var highlighter_ref = preload("res://Demo/Ui/GenomeUi/Highlighter.tscn")

	
@onready var id = $Layout/GenomeInfo/TabNameContainer/GridContainer/Id
@onready var fitness = $Layout/GenomeInfo/TabNameContainer/GridContainer/Fitness
@onready var gen = $Layout/GenomeInfo/TabNameContainer/GridContainer/Gen

@onready var links = $Layout/NeuralInfo/TabNameContainer/GridContainer/Links
@onready var nodes = $Layout/NeuralInfo/TabNameContainer/GridContainer/Nodes
@onready var network_control = $Layout/NetworkContainer/Control

var genome: Genome = null
var network: NeuralNet = null

var highlighter

func _ready() -> void:
	id.text = "Id: " + str(genome.genome_id)
	fitness.text = "Fitness: " + str(genome.fitness)
	gen.text = "Gen: " + str(genome.generation)



	network = genome.agent.network
	
	links.text = "Links: " + str(network.enabled_links.size())
	nodes.text = "Nodes: " + str(network.all_neurons.values().size())
	
	_highlight()
	_draw_network()

func _draw_network() -> void:
	network_control.draw_net(network)

func _highlight() -> void:
	if highlighter:
		highlighter.queue_free()
		highlighter = null
	
	highlighter = highlighter_ref.instantiate()
	var node_descriptor = "G: " + str(genome.genome_id)
	highlighter.get_node("IdLabel").text = node_descriptor
	if genome and genome.agent and genome.agent.body and is_instance_valid(genome.agent.body):
		genome.agent.body.add_child(highlighter)

func load_genome(genome_data: Genome) -> void:
	$Layout/Header.set_window_name("Genome: " + str(genome_data.genome_id))
	genome = genome_data

func _on_tree_exiting() -> void:
	if highlighter and is_instance_valid(highlighter):
		highlighter.queue_free()
		highlighter = null
