extends Node

"""This class is currently unused. If at any point multiple GA's are run in parallel
	Then this would behave as the controller. """

var ga_instances: Dictionary = {} # Dictionary<string, GeneticAlgorithm>

var is_paused: bool = false


# PUBLIC API START

func new_genetic_algorithm(params: Params) -> GeneticAlgorithm:
	var params_id = params.params_id
	if ga_instances.find_key(params_id):
		push_error("A GeneticAlgorithm instance already exists with the ID: ", params_id)
		return
	
	var _new_genetic_algorithm = GeneticAlgorithm.new()
	ga_instances[params_id] = _new_genetic_algorithm
	
	
	_new_genetic_algorithm._create_initial_population()
	
	return _new_genetic_algorithm

func set_pause_state(paused: bool) -> void:
	is_paused = paused

	for ga: GeneticAlgorithm in ga_instances.values():
		ga.set_is_paused(paused)
		print_highest_performer()
		


# PRIVATE API START
func _physics_process(delta) -> void:
	"""Car agents update their networks every time_step seconds, and then drive
	according to the networks output.
	"""
	if not is_paused:
		_game_cycle(delta)
		

func _game_cycle(delta: float) -> void:
	"""Evaluation of genomes can be done here, however with rtNEAT genomes are 
		not evaluated all at once. Instead genome evaluation is done by 
		picking a few genomes out of the general population and evaluating them. 
	"""

	for ga: GeneticAlgorithm in ga_instances.values():
		ga.next_timestep()
	
func print_highest_performer():
	
	var highest_fitness = 0
	var highest_performing_genome: Genome
	var highest_performing_species: Species
	var species_count = 0
	var genomes_count = 0
	for species: Species in SpeciesController.alive_ga_species.values():
		var species_genomes = species.species_evaluated_genomes
		species_count += 1
		for genome: Genome in species_genomes:
			genomes_count += 1
			if genome.agent.body.fitness > highest_fitness:
				highest_performing_species = species
				highest_fitness = genome.agent.body.fitness
				highest_performing_genome = genome
	
	
	print("Highest fitness: ", highest_fitness, " between ", species_count, " species and " , genomes_count , " genomes ")
	print(highest_performing_genome)
	
	if highest_performing_genome:
		var links = highest_performing_genome.links.values()
		for link in links:
			link.print_rep()
		var neurons = highest_performing_genome.neurons.values()
		for neuron in neurons:
			neuron.print_rep()



