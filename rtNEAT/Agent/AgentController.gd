class_name AgentController
"""Responsible for tracking agents within the world created by the algorithm.
	Agents are assigned from alive -> dead on GA timestep.
"""


static var all_ga_agents: Dictionary = {} # Dictionary<String: species_sid, Array<Agent>>

static var alive_ga_agents: Dictionary = {} # Dictionary<String: species_sid, Array<Agent>>

static var dead_ga_agents: Dictionary = {} # Dictionary<String: species_sid, Array<Agent>>

# PUBLIC API START ---------------------------------------------------------

static func add_species(sid: String) -> void:
	all_ga_agents[sid] = []
	alive_ga_agents[sid] = []
	dead_ga_agents[sid] = []
static func add_species_alive_agent(sid: String, agent: Agent) -> void:
	alive_ga_agents.get(sid).append(agent)
static func try_remove_species_alive_agent(sid: String, agent: Agent) -> bool:
	var agent_array: Array = alive_ga_agents.get(sid)
	var agent_index = agent_array.find(agent)
	
	if agent_index >= 0:
		alive_ga_agents[sid].remove_at(agent_index)
		return true
	return false	
	
static func set_species_alive_agents(sid: String, agents: Array) -> void:
	alive_ga_agents[sid] = agents
static func get_species_alive_agents(sid: String) -> Array: #Array<Agent>
	return alive_ga_agents.get(sid)

	
static func get_all_agents() -> Array:
	var agents: Array = [] 
	for agentArray: Array in alive_ga_agents.values():
		for agent: Agent in agentArray:
			agents.append(agent)
	return agents

static func set_species_dead_agents(sid: String, agents: Array) -> void:
	dead_ga_agents[sid] = agents
static func get_species_dead_agents(sid: String) -> Array: #Array<Agent>
	return dead_ga_agents.get(sid)



