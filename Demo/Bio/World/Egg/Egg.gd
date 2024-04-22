extends RigidBody2D

const egg_energy = 250
const GROWTH_TIME = 5.0

var spawn_func_state: GDScriptFunctionState
var g_id: int
var destroyed: bool = false

func _start_assign_genome_id(id: int):
	g_id = id

func _ready() -> void:
	set_gravity_scale(0.0)
	#connect("body_entered", self, "try_eat")
	
func try_eat(body):
	print("Body_entered!")
	if body.is_in_group("bodies"):
		print("EGG_EAT")
		body._give_food(egg_energy)
		disconnect("body_entered", self, "try_eat")
		destroyed = true
		queue_free()
	

func spawn_agent_in(agent: Agent, time: float):
	var spawn_func_state = yield(get_tree().create_timer(GROWTH_TIME), "timeout")
	if destroyed:
		return

	if not is_instance_valid(agent) or not is_instance_valid(agent.body):
		queue_free()
		return
		
	agent.body.global_rotation = Utility.random_i_range(-180, 180)
	agent.body.global_position = global_position
	get_parent().add_child(agent.body)
	queue_free()
