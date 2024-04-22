extends Node



"""This class is responsible for generating genomes, placing them into species and
evaluating them. It can be viewed as the main orchestrator of the evolution process,
by delegating the exact details of how each step is achieved to the other classes
within this directory.
"""

@onready var SpawnArea: Area2D = get_node("SpawnArea")
@onready var SpawnNode: Node2D = SpawnArea.get_node("Spawned")
@onready var SpawnShape: CollisionShape2D = SpawnArea.get_node("SpawnShape")

@onready var FoodScene: PackedScene = load("res://Demo/Bio/World/Food/Food.tscn")
@onready var FoodArea: Area2D = get_node("FoodArea")
@onready var FoodSpawned: Node2D = FoodArea.get_node("SpawnedFood")
@onready var FoodSpawnShape: CollisionShape2D = FoodArea.get_node("SpawnShape")

@onready var Random: RandomNumberGenerator = RandomNumberGenerator.new()

var is_paused: bool = false

# 1.0 = one second. time gets reset every time_step, then all agents get updated
var cycle_time: float= 0
# total_time gets reset every time a new generation is started
var total_time: float= 0
# every time_step the network takes sensory information and decides how to act
var TIME_STEP: float= 0.2
# counter to next evaluation
var evaluation_time: float = 0
# evaluation step
const EVALUATION_STEP = 5

var createdFoodAmount: int= 0
const FOOD_TARGET_AMOUNT: int= 800

func _ready() -> void:
	"""Sets the undefined members of the Params Singleton according to the options
	in the constructor. Body path refers to the filepath for the agents body.
	Creates the first set of genomes and agents, and creates a GUI if use_gui is true.
	"""
	
	var params_name: String = "Bio"
	Params.load_config(params_name)
	print("BIO READY")

func set_is_paused(paused: bool) -> void:
	is_paused = paused

var step_count = 0
func _physics_process(delta: float) -> void:
	"""Loops through all species and their genomes, removing agents who have been killed.
	Evaluates and reproduces and spawns new genomes and their representative agents.
	After which new inputs are provided to agents.
	"""
	if is_paused:
		return

	cycle_time += delta; total_time += delta; evaluation_time += delta
	
	
	if evaluation_time > EVALUATION_STEP:
		#print("BIO PHYSICS PROCESS")
		SpeciesController.filter_and_set_alive_agents()
		var adjusted_avg_fitness = SpeciesController.evaluate_all_species()
		SpeciesController.spawn_next_generation(adjusted_avg_fitness)
		evaluation_time = 0
		
		#print("Step: ", step_count, " _ msec: ", Time.get_ticks_msec())
		#print_highest_performer()
	
	if cycle_time > TIME_STEP:
		var alive_agents = SpeciesController.gather_alive_agents()
		var minimum_pop_boundary: int = alive_agents.size() - Params.minimum_population_size
		if minimum_pop_boundary < 0:
			for i in abs(minimum_pop_boundary):
				_create_minimal_agent()
			
		for agent: Agent in alive_agents:
			if Params.use_spawning and not agent.has_spawned:
				_spawn(agent)
			agent.process_inputs()
		cycle_time = 0
	

	if FoodSpawned.get_child_count() < FOOD_TARGET_AMOUNT:
		_spawn_food()
	

	step_count += 1


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
			if genome.agent.has_spawned and genome.agent.body.get_fitness() > highest_fitness:
				highest_performing_species = species
				highest_fitness = genome.agent.body.get_fitness()
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
	SpawnNode.add_child(agent.body)
	agent.has_spawned = true
	
	if not agent.body.reproduction_info:
		_apply_random_position_and_orientation(agent.body)

func _apply_random_position_and_orientation(body: RigidBody2D):
	var random_position: Vector2 = _get_random_position_in_body(SpawnShape)
	body.set_position(random_position)
	
	var random_rotation: float = _get_random_rotation()

	body.set_rotation(random_rotation)
	
	
func _get_random_position_in_body(collision_shape: CollisionShape2D) -> Vector2:
	var area_extents:Vector2 = collision_shape.shape.get_size()
	Random.randomize()
	
	var rand_x = Random.randf_range(-area_extents.x, area_extents.x)
	var rand_y = Random.randf_range(-area_extents.y, area_extents.y)
	

	var random_position = Vector2(rand_x, rand_y)
	return random_position

func _get_random_rotation() -> float:
	Random.randomize()
	
	var random_rotation = Random.randi_range(0, 180)
	return random_rotation



func _spawn_food() -> void:
	"""Create food spawner"""
	var food = FoodScene.instantiate()

	var randomPosition: Vector2= _get_random_position_in_body(FoodSpawnShape)
	
	createdFoodAmount += 1
	FoodSpawned.add_child(food)
	food.global_position = randomPosition
