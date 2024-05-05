extends Node


var dead_ga_species: Dictionary = {} # Dictionary<String,Species>
var alive_ga_species: Dictionary = {} # Dictionary<String,Species>
		
#TODO!!! Ensure SpeciesId can be used as integer
var latest_genome_id: int = 0
var latest_species_id: int = 0

var dead_genome_queue: Array = [] # Array<Genome>



func gather_alive_agents() -> Array: # Array<Agent>
	var agents = []
	for species: Species in alive_ga_species.values():
		var species_agents: Array = AgentController.get_species_alive_agents(species.species_sid)
		agents.append_array(species_agents)
	return agents

func evaluate_all_species() -> float:
	"""Evaluates running species within the GA and selects the worst performing 
	species to be culled and replaced with better-performing members. 
	
	If a species is performing poorly, it is not immediately culled. 
	The generation of the species must be more than 
	minimum_cull_generation for it to be removable. This signifies that 
	the species has not improved within a given amount of generations.
	"""
	##Returns total average adjusted fitness
	var _total_avg_fitness = 0.001
	var total_adj_avg_fitness = 0.001
	for species:Species in alive_ga_species.values():
		if not species.any_genome_alive() or species.obliterate:
			dead_ga_species[species.species_sid] = species
			alive_ga_species.erase(species.species_sid)
			continue
			
		species.evaluate()
		total_adj_avg_fitness += species.get_avg_adjusted_fitness()
		_total_avg_fitness += species.get_avg_fitness()	
	
	return total_adj_avg_fitness
	
	

func spawn_next_generation(total_avg_adj_fitness: float) -> void:
	var shared_population_size = Params.maximum_population_size
	for species:Species in alive_ga_species.values():
		var species_adj_fitness = species.get_avg_adjusted_fitness()
		var allowed_population_size = round(( species_adj_fitness / total_avg_adj_fitness ) * shared_population_size)
		var replacement_threshold = Params.population_replacement_threshold
		var amount_to_replace = round(allowed_population_size * replacement_threshold)
		
		#print(species_adj_fitness, "_", total_avg_adj_fitness, "_", shared_population_size)
		#print(allowed_population_size, "_", replacement_threshold)
		#print("Population size for species: ", species.species_sid, " is: ", allowed_population_size, " which will replace: ", amount_to_replace)
		
		if allowed_population_size > Params.maximum_population_size:
			push_error("Allowed population size exceeded Params maxmium_population_size")

		species.update_reproduction_pools(allowed_population_size, amount_to_replace)
		
		species.reproduce_species()
	

func filter_and_set_alive_agents():
	#filter alive agents
	for species: Species in alive_ga_species.values():
		var genomes: Array = species.species_alive_genomes
		var alive_genomes: Array = [] 

		for genome: Genome in genomes:
			if not genome.is_dead():
				alive_genomes.append(genome)
		
		species.species_alive_genomes = alive_genomes
		


func create_and_register_new_genome():
	var params: Params = Params
	var genome = Genome.minimal(params)
	
	var species = assign_or_create_species(genome)
	genome.species_sid = species.species_sid

	return genome


func kill_species(species_sid: String) -> void:
	var species = alive_ga_species.get(species_sid)
	alive_ga_species.erase(species_sid)
	dead_ga_species[species_sid] = species
	
	species.kill()
	

func assign_or_create_species(new_genome: Genome) -> Species:
	"""Tries to find a species to which the given genome is similar enough to be
	added as a member. If no compatible species is found, a new one is made. Returns
	the species.
	"""
	var found_species: Species
	# try to find an existing species to which the genome is close enough to be a member
	var comp_score = Params.species_boundary
	for species: Species in alive_ga_species.values():
		var rep: Genome = species.get_representative()
		if new_genome.get_compatibility_score(rep) < comp_score:
			
			comp_score = new_genome.get_compatibility_score(species.representative)
			found_species = species
			alive_ga_species[found_species.species_sid].add_member(new_genome)
			return found_species
	# new genome matches no current species -> make a new one
	if typeof(found_species) == TYPE_NIL:
		found_species = new_species_from_genome(new_genome)
		alive_ga_species[found_species.species_sid].add_member(new_genome)
		# return the species, whether it is new or not
	return found_species

func new_species_from_genome(founding_member: Genome) -> Species:
	"""Generates a new species with a unique id, assigns the founding member as
	representative, and adds the new species to curr_species and returns it.
	"""

	var new_species_sid = str(latest_species_id) + "_" + str(founding_member.genome_id)
	var new_species = Species.new(new_species_sid, founding_member)
	new_species.representative = founding_member
	alive_ga_species[new_species_sid] = new_species
	latest_species_id += 1
	return new_species

func get_incremented_genome_id() -> int:
	latest_genome_id += 1
	return latest_genome_id


func make_hybrid() -> Genome:
	"""Go through every species num_to_spawn times, pick it's leader, and mate it
	with a species leader from another species.
	"""
	if alive_ga_species.size() <= 1:
		push_warning("Less than one species, unable to make_hybrids")
		return 
	
	var amount_of_old_species = 0
	for species: Species in alive_ga_species.values():
		if species.age != 0:
			amount_of_old_species += 1
	
	if amount_of_old_species <= 1:
		push_warning("All species are new and not evaluated, unable to make_hybrids")
		return 
	

	var source_species = _get_random_species()
	var target_species = _get_random_species()
	while source_species == target_species:
		target_species = _get_random_species()
	# ignore newly added species

	var mom: Genome = source_species.leader
	if not mom:
		mom = source_species.representative

	var dad: Genome = target_species.leader
	if not dad:
		dad = target_species.representative
	var baby: Genome = mom.crossover(dad)

	var _found_species = assign_or_create_species(baby)

	var agent: Agent = baby.generate_agent()
	
	if is_instance_valid(mom.agent.body):
		var reproduction_info = mom.agent.body.get_reproduction_info()
		agent.body.set_reproduction_info(reproduction_info)
		
	if dad.generation > mom.generation:
		baby.generation = dad.generation + 1
	else:
		baby.generation = mom.generation + 1
		
	return baby
	
func _get_random_species() -> Species:
	var species_keys = alive_ga_species.values()
	var species: Species = Util.random_choice(species_keys)
	
	while species.age == 0:
		species = Util.random_choice(species_keys)
	
	return species
