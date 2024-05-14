extends Node

"""This class currently handles pausing, but can also handle running multiple GA's if
the handling of agents and species is modified. Currently unsupported. """

var ga_instances: Dictionary = {} # Dictionary<string, GeneticAlgorithm>

var is_paused: bool = false


# PUBLIC API START

func set_pause_state(paused: bool) -> void:
	is_paused = paused


func get_is_paused() -> bool:
	return is_paused

	
func print_highest_performer():
	
	var highest_fitness = 0
	var highest_performing_genome: Genome
	var _highest_performing_species: Species
	var species_count = 0
	var genomes_count = 0
	for species: Species in SpeciesController.alive_ga_species.values():
		var species_genomes = species.species_evaluated_genomes
		species_count += 1
		for genome: Genome in species_genomes:
			genomes_count += 1
			if genome.agent.body.fitness > highest_fitness:
				_highest_performing_species = species
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


func get_highest_performing_genome():
	var highest_fitness = 0
	var highest_performing_genome: Genome
	var _highest_performing_species: Species
	var species_count = 0
	var genomes_count = 0
	for species: Species in SpeciesController.alive_ga_species.values():
		var species_genomes = species.species_evaluated_genomes
		species_count += 1
		for genome: Genome in species_genomes:
			genomes_count += 1
			if genome.agent.body.fitness > highest_fitness:
				_highest_performing_species = species
				highest_fitness = genome.agent.body.fitness
				highest_performing_genome = genome
	return highest_performing_genome
