class_name GeneticAlgorithm
extends Node



"""This class is responsible for generating genomes, placing them into species and
evaluating them. It can be viewed as the main orchestrator of the evolution process,
by delegating the exact details of how each step is achieved to the other classes
within this directory.
"""

var is_paused: bool = false


func _init(custom_params_name: String = "Default") -> void:
	"""Sets the undefined members of the Params Singleton according to the options
	in the constructor. Body path refers to the filepath for the agents body.
	Creates the first set of genomes and agents, and creates a GUI if use_gui is true.
	"""
	if custom_params_name:
		Params.load_config(custom_params_name)
	

func set_is_paused(paused: bool) -> void:
	is_paused = paused

var step_count = 0
func next_timestep() -> void:
	"""Loops through all species and their genomes, removing agents who have been killed.
	Evaluates and reproduces and spawns new genomes and their representative agents.
	After which new inputs are provided to agents.
	"""
	if is_paused:
		return

	SpeciesController.filter_and_set_alive_agents()
	SpeciesController.evaluate_and_spawn()
	
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
	print("Step: ", step_count, " _ msec: ", Time.get_ticks_msec())
	GaController.print_highest_performer()

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

# ------ PRIVATE API START -----------------------------------------------------

func _spawn(agent: Agent):
	push_error("Spawning not implemented for default GA")
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
