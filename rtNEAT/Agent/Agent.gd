class_name Agent
extends RefCounted

""" Agents may only be created by the GeneticAlgorithm class. Agents generate the
entity that interacts with the world. This is the agents body. The Agent is also
provided upon its creation a neural network that was coded for by the genome that
generated the agent.

The Agent provides a sort of interface for the GA class to handle all interactions
between the body, controlled by a neural network, and the environment it lives in.

The body must have a method called act(), that uses the outputs of the neural network.
Furthermore a method called sense() must be provided, that returns an array containing
the observations from the environment which are used as inputs to the nn. The third
method that the body must have is called get_fitness(), which returns a POSITIVE
real or integer number that represents how well the agent has acted in this generation.

"""

# the body must be a scene.
var body = load(Params.agent_body_path).instantiate()
# Reference to the neural network that is encoded by the genome
var network: NeuralNet

var genome_id: int
var species_sid: String
var fitness = 0

# once set to true the agent can be removed from curr_agents in ga.next_timestep()
var is_dead = false
var has_spawned = false
# the highlighter shows the current location of the body in the world
var highlighter


func _init(s_sid: String, g_id: int, neural_net: NeuralNet) -> void:
	"""Called by genome.generate_agent(), requires a neural network to work.
	"""
	network = neural_net
	genome_id = g_id
	species_sid = s_sid

	# Groups are used to hide and show bodies with the GUI
	body.add_to_group("all_bodies")
	

	body.death.connect(on_body_death)



func process_inputs() -> void:
	"""Gets agent sensory information, feeds it to network, and passes
	network output to act method of the agent.
	"""
	var action = network.update(body.sense())
	body.act(action)


func on_body_death() -> void:
	"""Marks the agent as dead, assigns the fitness, and removes it from all groups
	"""
	is_dead = true
	fitness = body.get_fitness()
	# remove body from groups to make sure it receives no calls from change_visibility

	AgentController.try_remove_species_alive_agent(species_sid, self)

	for group in body.get_groups():
		if group in ["all_bodies", "leader_bodies"]:
			body.remove_from_group(group)

func die() -> void:
	if is_instance_valid(body):
		body.die()

func enable_highlight(enabled: bool) -> void:
	"""Used to show or hide the highlighter.
	"""
	if Params.is_highlighter_enabled:
		if body != null:
			if enabled:
				highlighter.show()
			else:
				highlighter.hide()
