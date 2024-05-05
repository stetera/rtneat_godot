extends Control

"""A demo that generates a network that simulates an XOR gate. The network receives
rewards dependant on how close the output is to the actual solution (either 0 or 1)
for every one of the four XOR cases. The maximum fitness that could be achieved for
solving every case is 4, but due to the weights never quite reaching full integers,
the threshold for solving the problem should show a bit of tolerance (like 3.999).

This demo follows the model of the other demos where there are bodies that interact
in the world. Here they are just simple nodes that do nothing else but compare their
output to the correct solution and assign a fitness. This is quite bloated, but it just
exists to demonstrate that NEAT for Godot can solve XOR. However, this Library is
intended for evolving agents that interact in game/simulation environments, and it
should not be used to generate classifiers (as there are much better ways of doing that).
"""

# fitness gets incremented every time the network calculates an output for one of
# the four xor_inputs. The closer the output is to the solution, the higher the reward.
var fitness = 0
# The four cases of an xor gate.
var xor_inputs = [[0, 0], [0, 1], [1, 0], [1, 1]]
var current_index = 0
# the currently selected xor_input. 
var curr_input: Array
# emitted as soon as the xor_tester has worked on every input.
signal death
# if any information needs to be passed to offspring, it can be held in reproduction_info
var reproduction_info

var ready_for_reproduction = false

var result_table = {"0" = null, "1" = null, "2" = null, "3" = null}

func sense() -> Array:
	"""Selects a new input to solve when act() gets called."""
	if ready_for_reproduction: 
		return curr_input
	curr_input = xor_inputs[current_index]

	return curr_input


func act(xor_output: Array) -> void:
	"""Calculates how good the solution of the network (xor_output) was by calculating
	the delta between correct answer and output."""
	if ready_for_reproduction:
		return
		
	var xor_answer: float = xor_output[0]
	
	result_table[str(current_index)] = xor_answer
	current_index += 1
	var expected: float = float(curr_input[0] != curr_input[1])
	var distance_squared: float = pow((expected - xor_answer), 2)
	fitness += (1 - distance_squared)
	
	if current_index >= 4:
		ready_for_reproduction = true

func set_reproduction_info(info) -> void:
	reproduction_info = info
	
func get_reproduction_info():
	return reproduction_info

func get_fitness() -> float:
	return fitness

func print_result() -> void:
	print(result_table)
	
func die() -> void:
	return
