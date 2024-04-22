extends Node2D

"""This is an example initializes. Which starts the XOR Demo for demonstrating the 
	genetic algorithm. 
"""

# while the splashscreen is open, do not continue the genetic algorithm
var is_paused: bool = false

var running_genetic_algorithms: Array = [] # Array<GeneticAlgorithm>
# The parent node of the buttons that a correspond to loading a demo scene
@onready var launchers = $MarginContainer/VBoxContainer/Launchers

func _ready() -> void:
	"""Connect the button signals to appropriate loading methods
	""" 
	launchers.get_node("BioLauncher").connect("pressed", load_bio_demo_scene)
	launchers.get_node("XorLauncher").connect("pressed", load_xor_scene)


func load_bio_demo_scene() -> void:
	"""Copy lander params to user://Configs/ and switch to lander scene.
	"""
	get_tree().change_scene_to_file("res://Demo/Bio/BioMain.tscn")


func load_xor_scene() -> void:
	"""Copy XOR params to user://Configs/ and switch to XOR scene.
	"""
	get_tree().change_scene_to_file("res://Demo/Xor/XorMain.tscn")

#
#func _ready() -> void:
	#
		#var ga = GaController.new_genetic_algorithm(Params)
		#running_genetic_algorithms.append(ga)
		#add_child(ga)
		#
		#get_node("Control").start(ga)
	#
	## Press DEMO -> Start demo
	

	#
#func _input(event) -> void:
	#if event.is_action_pressed("print"):
		#print("WORKS")
		#GaController.print_highest_performer()
	##push_warning("Input not implemented yet")
