extends Node

@onready var canvas = $CanvasLayer

@onready var genome_view = preload("res://Demo/Ui/GenomeUi/GenomeView.tscn")

var is_paused: bool = false
var genome_display: Control = null

func _ready() -> void:
	"""Sets the undefined members of the Params Singleton according to the options
	in the constructor. Body path refers to the filepath for the agents body.
	Creates the first set of genomes and agents, and creates a GUI if use_gui is true.
	"""
	var params_name: String = "XOR"
	Params.load_config(params_name)
	

func set_is_paused(paused: bool) -> void:
	is_paused = paused

var step_count = 0
const display_best_boundary = 0.5
var display_best_counter = 0
var best_genome
func _physics_process(delta: float) -> void:
	"""Loops through all species and their genomes, removing agents who have been killed.
	Evaluates and reproduces and spawns new genomes and their representative agents.
	After which new inputs are provided to agents.
	"""
	if is_paused:
		if not best_genome:
			return
		
		display_best_counter += delta
		if display_best_counter > display_best_boundary:
			display_best_counter = 0	
			_cycle_best_genome_inputs(best_genome)
		return
		

	SpeciesController.filter_and_set_alive_agents()
	var adjusted_avg_fitness = SpeciesController.evaluate_all_species()
	SpeciesController.spawn_next_generation(adjusted_avg_fitness)
	
	var alive_agents = SpeciesController.gather_alive_agents()

	var minimum_pop_boundary: int = alive_agents.size() - Params.minimum_population_size
	if minimum_pop_boundary < 0:
		for i in abs(minimum_pop_boundary):
			_create_minimal_agent()
		
	for agent: Agent in alive_agents:
		if Params.use_spawning and not agent.has_spawned:
			_spawn(agent)
		agent.process_inputs()

	step_count += 1

	var best_found_genome = GaController.get_highest_performing_genome()
	if best_found_genome:
		if best_found_genome.fitness >= 3.99:
			best_genome = best_found_genome
			is_paused = true
		_display_genome(best_found_genome)

	#GaController.print_highest_performer()

func _display_genome(genome: Genome) -> void:
	if genome_display:
		genome_display.queue_free()
		genome_display = null
	
	genome_display = genome_view.instantiate()
	genome_display.load_genome(genome)
	canvas.add_child(genome_display)
	
var xor_inputs = [[0, 0], [0, 1], [1, 0], [1, 1]]
var xor_index = 0
func _cycle_best_genome_inputs(genome: Genome) -> void:
	var net = genome.agent.network
	var result = net.update(xor_inputs[xor_index])

	xor_index += 1
	if xor_index >= 4:
		xor_index = 0
	

func _create_initial_population() -> Array:
	"""This method creates the first generation of genomes. 
	
	The first genomes should be minimal and contain as little information as required. 
	This is defined by Params.initial_neurons
	
	Every genome gets assigned to a species, new species are created
	if necessary. Returns an array of the current genomes.
	"""
	var genomes: Array = []

	for i in Params.minimum_population_size:
		_create_minimal_agent()
	
	return genomes

func _create_minimal_agent() -> Agent:
	var genome: Genome = SpeciesController.create_and_register_new_genome()
	
	# TODO ENSURE AGENT GENERATION CORRECT
	var agent = genome.generate_agent()

	return agent



func sort_by_spec_fitness(species1: Species, species2: Species) -> bool:
	"""Used for sort_custom(). Sorts species in descending order.
	"""
	return species1.avg_fitness > species2.avg_fitness


func _spawn(_agent: Agent) -> void:
	return


#"""TODO REFACTOR
#func print_status() -> void:
	#"""Prints some basic information about the current progress of evolution.
	#"""
	#var print_str = """\n Last generation performance:
	#\n innovation number: {inn_num} \n number new species: {new_s}
	#\n number dead species: {dead_s} \n total number of species: {tot_s}
	#\n avg. fitness: {avg_fit} \n best fitness: {best} \n """
	#var print_vars = {"inn_num" : Innovations.innovation_id, "new_s" : SpeciesController.species_count,
					  #"dead_s" : SpeciesController.dead_species_count, "tot_s" : curr_species.size()}
	#print(print_str.format(print_vars))
#"""
