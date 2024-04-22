extends Node

"""This singleton holds all Params that are used by the NEAT algorithm."""

# -------------------- GENETIC ALGORITHM SETTINGS -------------------- 

var params_id = "Default"

var simulation_stop_fitness = 3.99

# numbers of inputs and outputs that every neural net will have
var num_inputs: int = 2
var num_outputs: int = 1
# A path to the agent_body - the scene that represents the player, providing the
# sense(), act() and get_fitness() functions. This parameter is set by the user
# when a new GeneticAlgorithm node gets instanced.
var agent_body_path: String = "res://demo/Agent/XorAgent.tscn"

# Amount of agents the simulation is limited to
var maximum_population_size:int = 300
# This is optional. if there are less, a new minimal genome is created
# Current system tries to fill up to maximum_population_size immediately.
var minimum_population_size:int = 300


# percentage of poorest performing population replaced each cycle
var population_replacement_threshold = 0.9
# to avoid evaluating genomes with the current pool who haven't yet had time to
# adjust with the environment, at which step is the genome subject to evaluation
var evaluation_step = 5

# should agent bodies be spawned?
var use_spawning = false

var prob_asex = 0.25
# probability of gene being inherited from the less fit parent. Lower number better.
var gene_swap_rate = 0.4

# -------------------- NETWORK CONSTRAINTS -------------------- 

# Because starting minimally is a very important factor in NEAT, this parameter
# determines how many input links get a connection to an output link, when creating
# the first set of genomes. My personal experience thus far has shown that this
# is one of the most crucial Params for good performance. It is important to
# keep this number low, but definitely not too low. 40%-50% of the num of inputs
# is a good target to start with. It should also approach the number of inputs that
# are assumed to be important.
var num_initial_links = 2
# maximum amount of neurons, for performance reasons. can be set arbitrarily
var max_neuron_amt = 100

# ----- Chaining
# if prevent_chaining is true, only split links that connect to neurons having
# x values of either 0 or 1. This means that networks do not exceed a depth
# of one hidden layer until their amount of neurons exceeds this threshold.
var prevent_chaining = true
var chain_threshold = 2

# -------------------- NEURAL_NET Params -------------------- 

# ----- Network updates
# Should the network ensure that all inputs have been fully flushed through
# the network (=snapshot), or should it give an output after every neuron has
# been activated once (= active)
var is_runtype_active = true
# Change the activation function used in the neural network. Curr_activation func
# must be a string that exactly matches one of the activation function definitions,
# since it is directly used as a parameter for creating a funcref in the NeuralNet
# class. Currently implemented activation functions are: "sigm_activate",
# "tanh_activate", "gauss_activate"
var curr_activation_func = "sigm_activate"
# if set to true, input neurons pass their inputs through the defined activation
# function.
var activate_inputs = false

# ----- Network drawing
# colors of neuron types, when displaying a network. Map to NEURON_TYPE enum
var neuron_colors = [Color.TURQUOISE, Color.TEAL, Color.SEASHELL, Color.TOMATO]
# When coloring weights, weights >= num are colored red, weights <= are blue, 
# and everything inbetween uses this num as reference.
var weight_max_color = 4


# -------------------- NEURON MUTATIONS --------------------

# ----- Adding neurons
# probabilities of adding a neuron in mutation func. There are two values for mutations,
# because if a species is stale for a while it's mutation probabilities are changed
# to the second value
var prob_add_neuron = [0.05, 0.1]
# default activation curve that neurons are initialized with. tanh default is 2.
# the other defaults can be found in the activation function definitions in the
# neuralnet class.
var default_curve = 5.0

# ----- activation function mutations
# probabilities of changing the curve of the activation function. This mutation
# is applied on every link, meaning about this num reflects the percent of all
# neurons that will be changed.
var prob_activation_mut = [0.0, 0.0]
# activation gets increased/decreased by normal distribution. This is it's deviation.
var activation_shift_deviation = 0.3

# ----- fitness sharing parameters
# Params for rewarding/punishing species based on their age
var old_age = 8
var youth_bonus = 1.3
var old_penalty = 0.8

# -------------------- LINK MUTATIONS --------------------

# ----- adding links
# probabilities of adding a link between random neurons in mutation func
var prob_add_link = [0.1, 0.2]
# probability of disabling a single link per mutation
var prob_disable_link = [0.0, 0.0]
# probabilities of adding a looping link (link that connects neuron to itself)
var prob_loop_link = [0, 0]
# probabilities of adding a direct link (link that directly connects input to output
# neurons). Useful when starting with few links, or when no good Innovations occur.
var prob_direct_link = [0, 0]

# disable mutations that produce feed back links
var no_feed_back = true
# number of attempts to find a neuron if there is no guarantee one will be found
var num_tries_find_link = 10


# ----- mutating weights
# probabilities of changing the weight of a link. This mutation is applied on every
# link, meaning about this num reflects the perc. of all links that will be changed
var prob_weight_mut = [0.6, 0.8]
# range in which new weights should be initialized
var w_range = 4.0
# completely changes weight. This can only happen if the the probability of a
# weight mutation is met. Therefore the prob is prob_weight_mut * prob_weight_replaced 
var prob_weight_replaced = [0.2, 0.4]
# weight gets increased/decreased by normal distribution. This is it's deviation.
var weight_shift_deviation = 0.3


# -------------------- SPECIATION --------------------

# ----- speciation and compatibility Params
# minimum compatibility score for two genomes to be considered in the same species
var species_boundary = 2.5
# coefficients for tweaking the compatibility score
var coeff_matched = 0.6
var coeff_disjoint = 1.2
var coeff_excess = 1.4


# -------------------- SPECIES BEHAVIOR --------------------

# ----- species performance tracking
# if species start to become stale and don't improve for enough_gens_to_change_things 
# change MUTATION_STATE from normal to heightened. This will cause the second
# probability of the mutation options to be chosen when spawning new members.
var enough_gens_to_change_things = 7
# how many generations should be tolerated without improvement, after that, kill
# the species.
var allowed_gens_no_improvement = 20
# kill genomes who have already been evaluated and have survived for another generation
var purge_stale = true


# ----- change visibility of agent bodies
# If rendering costs too much performance, or clutter is to be avoided, agent.body
# nodes can be hidden using ga.update_visibility()
var visibility_options = ["Show all", "Show Leaders", "Show none"]
# the default visibility is an index to the visibility options. 0 = show all
# this setting can be changed during runtime via a species list popup
var default_visibility = 0



# ---------------------------------------------------------------
# ------------------ SAVING AND LOADING PARAMS ------------------
# ---------------------------------------------------------------

func load_config(config_name: String) -> void:
	"""Loads a valid file stored in res://Configs/ that has a .cfg extension.
	If no configs have been saved yet, the /params_configs directory is made, and
	a config named 'Default.cfg' is saved with the properties of this class.
	"""

	var config = ConfigFile.new()
	# If no param configs have been saved yet, save the settings from this file as Default
	var dir: DirAccess = DirAccess.open("res://Configs")
	if not dir:
		dir = DirAccess.open("res://")
		dir.make_dir("Configs")
		save_config("Default")
	# try to open the specified file, break execution if it doesn't exist
	else:
		var err = config.load("res://Configs/%s.cfg" % config_name)
		if err == OK:
			for section in config.get_sections():
				for property in config.get_section_keys(section):
					set(property, config.get_value(section, property))
		else:
			push_error("Could not load config, error code: %d" % err); breakpoint


func save_config(config_name: String) -> void:
	"""Saves the properties of this instance of Params as a .cfg file under 
	res://Configs/.
	"""
	var config = ConfigFile.new()
	for property in get_property_list():
		# cannot use match statement because array patterns have to match completely
		var has_property = false
		for section_key in property_dict.keys():
			if property_dict[section_key].has(property.name):
				config.set_value(section_key, property.name, get(property.name))
				has_property = true
				break
		if not has_property and not ignore_properties.has(property.name):
			print("property %s is missing in the property dict" % property.name)
	config.save("res://Configs/%s.cfg" % config_name)


# An array listing all the properties of this class that should be excluded from config
var ignore_properties = [
	"Node", "Pause", "owner", "custom_multiplayer", "Script", "__meta__",
	"Script Variables", "editor_description", "_import_path", "pause_mode",
	"name", "filename", "multiplayer", "process_priority", "script", "visibility_options", "default_visibility",
	"neuron_colors", "weight_max_color", "num_tries_find_link", "ignore_properties",
	"property_dict", "unique_name_in_owner", "scene_file_path", "Process", "process_mode",
	"process_physics_priority", "Thread Group", "process_thread_group", "process_thread_group_order",
	"process_thread_messages", "Editor Description", "Params.gd"
]

# Assigns all properties used in the config to section keys
var property_dict = {
	"Genetic Algorithm settings" : [
		"params_id",
		"maximum_population_size",
		"minimum_population_size",
		"print_new_generation",
		"simulation_stop_fitness",
		"population_replacement_threshold",
		"evaluation_step",
		"use_spawning",
		"purge_stale",
		"agent_body_path",
	],
	"network constraints" : [
		"num_inputs",
		"num_outputs",
		"num_initial_links",
		"max_neuron_amt",
		"prevent_chaining",
		"chain_threshold"
	],
	"GUI and highlighter" : [
		"use_gui",
		"is_highlighter_enabled",
		"highlighter_offset",
		"highlighter_radius",
		"highlighter_color",
		"highlighter_width"
	],
	"Crossover" : [
		"prob_asex",
		"gene_swap_rate",
		"random_mating"
	],
	"Neuron mutations" : [
		"prob_add_neuron",
		"default_curve",
		"prob_activation_mut",
		"activation_shift_deviation"
	],
	"Link mutations" : [
		"prob_add_link",
		"prob_disable_link",
		"prob_loop_link",
		"prob_direct_link",
		"no_feed_back",
		"prob_weight_mut",
		"w_range",
		"prob_weight_replaced",
		"weight_shift_deviation",
	],
	"Speciation" : [
		"species_boundary",
		"coeff_matched",
		"coeff_disjoint",
		"coeff_excess"
	],
	"Species behavior" : [
		"enough_gens_to_change_things",
		"allowed_gens_no_improvement",
		"old_age",
		"youth_bonus",
		"old_penalty",
		"update_species_rep",
		"leader_is_rep",
		"spawn_cutoff",
		"selection_threshold",
	],
	"Neural network settings" : [
		"is_runtype_active",
		"curr_activation_func",
		"activate_inputs",
	],
}
