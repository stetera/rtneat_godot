class_name Species
extends RefCounted

"""Species are a means for the NEAT algorithm to group structurally similar networks
together. The GeneticAlgorithm class uses species to provide new genomes by either
calling elite_spawn(), mate_spawn() or asex_spawn() on a species.

This grouping is necessary to achieve 'fitness sharing', meaning that the fitness
of individual members contributes to the fitness of the entire species, which in
turn determines how many new members the species will spawn in the next generation.
"""

var species_sid: String # latest_species_id + "_" + founding_member_genome_id)
var species_generated_timestamp: float = 0
# How many evaluations this species has existed for
var age = 0

# first genome generated, to which all other genomes are comapred to
var representative: Genome

# Leader is the fittest member. If Params.compare_to_leader, he is also the representative
var leader: Genome

var species_alive_genomes: Array = [] # Array<Genome>
var species_evaluated_genomes: Array = [] # Array<Genome>

var reproduction_pool: Array = [] # Array<Genome>
var replace_pool: Array = [] # Array<Genome>
var culling_pool: Array = [] # Array<Genome>

var avg_fitness = 0
var avg_fitness_adjusted = 0
var best_ever_fitness = 0
var num_gens_no_improvement = 0
var max_allowed_population = 1
var num_genomes_to_replace = 0

var obliterate = false
var curr_mutation_rate = Enums.MUTATION_RATE.normal

func _init(sid: String, founder: Genome) -> void:
	"""Creates a new species
	"""
	species_sid = sid
	
	representative = founder
	species_generated_timestamp = Time.get_unix_time_from_system()
	AgentController.add_species(sid)

func get_representative() -> Genome:
	return representative

func add_member(genome: Genome) -> void:
	genome.species_sid = species_sid
	species_alive_genomes.append(genome)
	
func any_genome_alive() -> bool:
	return species_alive_genomes.size() > 0

func get_evaluated_genomes() -> Array: # Array<Genome>
	return species_evaluated_genomes
func get_avg_adjusted_fitness() -> float:
	return avg_fitness_adjusted
func get_avg_fitness() -> float:
	return avg_fitness
	
	
func gather_evaluated_genomes() -> void:
	var evaluated_genomes: Array = []
	for genome: Genome in species_alive_genomes:
		if genome.eval_step > Params.evaluation_step:
			evaluated_genomes.append(genome)
	species_evaluated_genomes = evaluated_genomes

func purge_stale_genomes() -> void:
	for genome: Genome in species_alive_genomes:
		if genome.eval_step > Params.evaluation_step + 1 and not genome == leader:
			kill_genome(genome)

func calculate_avg_adjusted_fitness() -> void:
	"""Returns the average adjusted fitness of all members in the species
	"""
	var avg_adj_fitness = 0
	var evaluated_genomes = get_evaluated_genomes()
	for member: Genome in evaluated_genomes:
		var fit_modif = Params.youth_bonus if age < Params.old_age else Params.old_penalty
		avg_adj_fitness = avg_fitness * fit_modif
	
	avg_fitness_adjusted = avg_adj_fitness
	

func calculate_avg_fitness() -> void:
	"""Returns the average fitness of all members in the species
	"""
	var evaluated_genomes = get_evaluated_genomes()
	var total_fitness = 0
	for member: Genome in evaluated_genomes:
		if member.fitness:
			total_fitness += member.fitness
	
	if evaluated_genomes.size() <= 0:
		avg_fitness = 0
		return
	
	avg_fitness = (total_fitness / evaluated_genomes.size())

func sort_by_fitness(member1: Genome, member2: Genome) -> bool:
	"""Used for sort_custom(). Sorts members in descending order.
	"""
	return member1.fitness > member2.fitness

func elite_spawn() -> Genome:
	"""Returns a clone of the species leader without increasing spawn count
	"""
	return leader.clone()

func evaluate() -> void:
	if Params.purge_stale:
		purge_stale_genomes()
	
	for genome: Genome in species_alive_genomes:
		genome.eval_step += 1	 
		genome.fitness = genome.agent.body.get_fitness()
		
		print("Evaluated genome and its fitness is: ", genome.genome_id, " _: ", genome.fitness)
		if genome.fitness >= Params.simulation_stop_fitness:
			print(genome)
			#GaController.set_pause_state(true)
	
	# The order of calculations is important, as avg fitness is calculated from evaluated genomes
	gather_evaluated_genomes()
	calculate_avg_fitness()
	calculate_avg_adjusted_fitness()
	

func update_reproduction_pools(max_population: int, replace_count: int) -> void:
	"""Checks if the species continues to survive into the next generation. If so,
	the total fitness of the species is calculated and adjusted according to the age
	bonus of the species. It's members are ranked according to their fitness, and
	a certain percentage of them is placed into the pool that gets to produce offspring.
	"""
	# first check if the species has survived for too many generations without improving, 
	# in which case it is marked for obliteration. 
	if num_gens_no_improvement > Params.allowed_gens_no_improvement:
		obliterate = true
		return

	species_evaluated_genomes.sort_custom(sort_by_fitness)
	if species_evaluated_genomes.size() == 0:
		# species not ready yet
		return
	leader = species_evaluated_genomes[0]

	#print("Max allowed pop for species: ", species_sid, " = ", max_population)
	# update species specific reprodction limits
	max_allowed_population = max_population
	num_genomes_to_replace = replace_count
	
	set_mutation_rate()
	
	# Ensure we do not exceed max population. Cull species who are worst-performing within the species
	var current_genome_pool = species_evaluated_genomes
	if species_evaluated_genomes.size() > max_population:
		# reverse slice starting from worst members
		culling_pool = species_evaluated_genomes.slice(species_evaluated_genomes.size(), max_population, -1)
		current_genome_pool = species_evaluated_genomes.slice(0, max_population + 1)
	
	# keep elite
	if current_genome_pool.size() <= 1:
		replace_pool = []
	else:
		# assign random members who have not been culled
		var replace_target = current_genome_pool.size() - replace_count - 1
		for i in replace_target:
			var random_index = Util.random_i_range(1, current_genome_pool.size() - 1)
			var random_genome = current_genome_pool[random_index]
			replace_pool.append(random_genome)
		#replace_pool = current_genome_pool.slice(current_genome_pool.size(), replace_target, -1)
		#current_genome_pool = current_genome_pool.slice(0, current_genome_pool.size() - replace_pool.size())

	reproduction_pool = current_genome_pool


func reproduce_species():
	"""Goes through the culling pool and replaces the genomes to be culled with 
	other representatives from the reproduction pool through crossover or 
	asexual reproduction, until the max population size is reached. The new 
	genomes then generate an agent, which will handle the interactions between 
	the entity that lives in the simulated world, and the neural network that 
	is coded for by the genome.
	"""
	var new_genomes: Array = reproduction_pool # Array<Genome>
	
	#print("2FF Species: ", species_sid  ,": " ,  species_alive_genomes.size(),  ">>>",reproduction_pool.size()  , ">>>" ,replace_pool.size(), ">>>" ,culling_pool.size() )
	#print("MAX POP IS: ", max_allowed_population )
	if culling_pool.size() > (species_alive_genomes.size() + species_evaluated_genomes.size()) or max_allowed_population <= 0:
		#print("SPECIES SUBJECT TO CULLING: ", species_sid)
		for genome: Genome in species_alive_genomes:
			kill_genome(genome)
		SpeciesController.kill_species(species_sid)
		species_evaluated_genomes = []
		
		#print("Size species after culling: ", culling_pool.size(), " and alive genomes: ", species_alive_genomes.size())
		return


	# cull those in culling
	if culling_pool.size() > 0:
		print("\n", species_sid, " BEOFRE DELETE culling pool: ", culling_pool.size(), " and alive genomes: ", species_alive_genomes.size())
		for genome: Genome in culling_pool:
			kill_genome(genome)
		print(species_sid, "AFTER DELETE culling pool: ", culling_pool.size(), " and alive genomes: ", species_alive_genomes.size())
		
	# take as many as can be replaced and replace them
	if reproduction_pool.size() > 0: # empty with without evaluated genomes
		for genome: Genome in replace_pool:
			if not is_instance_valid(genome.agent.body):
				continue
			var reproduction_info = genome.agent.body.get_reproduction_info()
			var replacer_genome: Genome = Util.random_choice(new_genomes) 
			var replacer_offspring: Genome = reproduce(replacer_genome, reproduction_info)
			new_genomes.append(replacer_offspring)
		

	# take the amount we should be generating and generate up to amount
	while new_genomes.size() < max_allowed_population:

		if Util.random_f() < 0.2 and SpeciesController.alive_ga_species.size() >= 2:
			var hybrid = SpeciesController.make_hybrid()
			if hybrid:
				new_genomes.append(hybrid)
		else:
			var random_genome: Genome
			if new_genomes.size() == 0: # we have no reproduction pool
				if species_evaluated_genomes.size() > 0:
					random_genome = Util.random_choice(species_evaluated_genomes)
				else: 
					# we have no genome evaluated
					random_genome = Util.random_choice(species_alive_genomes)
			else:
				random_genome = Util.random_choice(new_genomes)	
			
			if not random_genome: 
				break
				
			var reproduction_info = random_genome.agent.body.get_reproduction_info()
			var random_offspring: Genome = reproduce(random_genome, reproduction_info)
			new_genomes.append(random_offspring)

	age += 1

func kill() -> void:
	for genome in species_alive_genomes:
		kill_genome(genome)
	return
	#print("KILLED SPECIES ", species_sid)

func reproduce(source_genome: Genome, reproduction_info = {}) -> Genome:
	var baby: Genome
	if species_evaluated_genomes.size() < 2 or species_evaluated_genomes.size() > 2 and Util.random_f() < Params.prob_asex:
		baby = asex_spawn(source_genome)
	else:	# produce a crossed-over genome
		baby = mate_spawn(source_genome)
	
	if not baby:
		push_warning("Failed to create a baby. Species died", source_genome.species_sid, " _ ", source_genome.genome_id)
		push_warning(species_alive_genomes)
		push_warning("AND: \n species_evaluated_genomes")
		push_warning(source_genome)
		return

	
	var _found_species = SpeciesController.assign_or_create_species(baby)

	var agent: Agent = baby.generate_agent()
	agent.body.set_reproduction_info(reproduction_info)
	return baby

func set_mutation_rate():
	# Handle mutation rate
	if leader.fitness > best_ever_fitness:
		# this means the species is improving -> normal mutation rate
		best_ever_fitness = leader.fitness
		num_gens_no_improvement = 0
		curr_mutation_rate = Enums.MUTATION_RATE.normal
	else:
		num_gens_no_improvement += 1
		if num_gens_no_improvement > Params.enough_gens_to_change_things:
			curr_mutation_rate = Enums.MUTATION_RATE.heightened


func kill_genome(genome: Genome) -> void:
	"""Kill a genome and remove it from tracked agents and this species. """
	try_remove_alive_genome(genome)
		
	AgentController.try_remove_species_alive_agent(species_sid, genome.agent)
	genome.agent.die()

	var found_genome_index = species_alive_genomes.find(genome)
	#print("FOUND_GENOME INDEX: ", found_genome_index)
	if found_genome_index >= 0:
		found_genome_index.error()
	else:
		var agents = AgentController.get_species_alive_agents(species_sid)
		for agent in agents:
			if agent == genome.agent:
				agent.error()
				
	return
	
func try_remove_alive_genome(genome: Genome)-> void:
	var found_genome_index = species_alive_genomes.find(genome)
	#print("FOUND_GENOME INDEX TO DELETE: ", found_genome_index)
	if found_genome_index >= 0:
		species_alive_genomes.remove_at(found_genome_index)
		
	var found_evaluated_index = species_evaluated_genomes.find(genome)
	#print("FOUND_EVALUATED INDEX TO DELETE: ", found_evaluated_index)
	if found_evaluated_index >= 0:
		species_evaluated_genomes.remove_at(found_evaluated_index)
	

func mate_spawn(mom: Genome) -> Genome:
	"""Chooses two members from the pool and produces a baby via crossover. Baby
	then gets mutated and returned.
	"""
	var dad: Genome; var baby: Genome
	# random mating, pick 2 random unique parent genomes for crossing over.
	var found_mate = false
	
	for potential_dad in species_evaluated_genomes:
		if potential_dad != mom:
			dad = potential_dad
			found_mate = true
	
	# species died or incorrect call to mate spawn due to small population
	if not mom or not dad:
		return
		
	baby = dad.crossover(mom)
	baby.mutate(curr_mutation_rate)
	
	if dad.generation > mom.generation:
		baby.generation = dad.generation + 1
	else:
		baby.generation = mom.generation + 1
	
	return baby

func asex_spawn(parent: Genome) -> Genome:
	"""Clones a member from the pool, mutates it, and returns it.
	"""
	var baby: Genome = parent.clone()
	baby.mutate(curr_mutation_rate)
	baby.generation = parent.generation + 1
	
	return baby 
