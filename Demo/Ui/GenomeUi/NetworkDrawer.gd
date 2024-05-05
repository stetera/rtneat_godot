extends Control

@onready var font = load("res://Demo/Ui/Other/Roboto-Regular.ttf")


var neural_net: NeuralNet
func draw_net(net: NeuralNet) -> void:
	neural_net = net
	
	net.updated.connect(_handle_redraw)
	 


func _handle_redraw(outputs: Array) -> void:
	queue_redraw()

func _draw() -> void:
	_redraw_graph()
	_reassign_outputs()


func _reassign_outputs() -> void:
	var neurons_dict = neural_net.all_neurons
	for neuron_id in neurons_dict.keys():
		# determine the position of the neuron on the canvas and it's color
		var neuron: Neuron = neurons_dict[neuron_id]
		var draw_pos = neuron.position * size
		var draw_col = Params.neuron_colors[neuron.neuron_type]
		# draw state
		var output = str(round(neuron.output*100)/100)
		draw_string(font, draw_pos - Vector2(35, -8), output, 0, -1, 16, Color.AQUA)


func _redraw_graph() -> void:
	var depth = neural_net.depth
	var neurons_dict = neural_net.all_neurons
	
	# track inputs and outputs if no neuron names are provided
	var input_index = 0
	var output_index = 0
	for neuron_id in neurons_dict.keys():
		# determine the position of the neuron on the canvas and it's color
		var neuron: Neuron = neurons_dict[neuron_id]
		var draw_pos = neuron.position * size
		var draw_col = Params.neuron_colors[neuron.neuron_type]
		
		# draw neuron labels based on input_neuron_name_config
		if neuron.neuron_type == Enums.NEURON_TYPE.bias:
			draw_string(font, neuron.position - Vector2(0, 10), "Bias")
		elif not neuron.neuron_type == Enums.NEURON_TYPE.output:
			if Params.input_neuron_name_config.size() > input_index:
				var text = Params.input_neuron_name_config[input_index]
				draw_string(font, neuron.position * size - Vector2(0, 10), text)
				input_index += 1
			else:
				var text = "Hidden"
				draw_string(font, neuron.position * size - Vector2(0, 10), text)
		else:
			if Params.output_neuron_name_config.size() > output_index:
				var text: String = Params.output_neuron_name_config[output_index]
				var offset = text.length() * 6.5
				draw_string(font, draw_pos - Vector2(offset, 10), text)
				output_index += 1
		
		# first draw all links connecting to the neuron
		for link in neuron.input_connections:
			# color strength is determined by how strong weight relative to wmc
			var w_col = Color(1, 1, 1, 1)
			var wmc = Params.weight_max_color
			var w_col_str = (wmc - min(abs(link[1]), wmc)) / wmc
			# color red by decreasing green and blue
			if link[1] >= 0:
				w_col.g = w_col_str; w_col.b = w_col_str
			# color blue by decreasing red and green
			elif link[1] <= 0:
				w_col.r = w_col_str; w_col.g = w_col_str
			# draw links as tris to indicate their firing direction
			var in_pos = link[0].position * size
			var spacing = Vector2(0, 5)
			var tri_points = PackedVector2Array([in_pos+spacing, draw_pos, in_pos-spacing])
			var colors = PackedColorArray([Color.WHITE, w_col])
			draw_primitive(tri_points, colors, tri_points)
		# finally draw the neuron last, so it overlaps all the links
		draw_circle(draw_pos, 6, draw_col)
		# mark if a loop link is connected to the neuron
		if neuron.loop_back:
			draw_char(font, draw_pos, "L")
