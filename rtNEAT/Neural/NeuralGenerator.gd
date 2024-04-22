class_name NeuralGenerator

# PUBLIC API START -----------------------------------------------------

static func create_initial_topology(params: Params) -> Dictionary: # Dictionary<String, Neuron>
	"""Currently unused"""
	var input_neurons: Dictionary = create_input_neurons(params) # Dictionary<String, Neuron>
	var output_neurons: Dictionary = create_output_neurons(params) # Dictionary<String, Neuron>
	var all_neurons = Util.merge_dicts(input_neurons, output_neurons)
	
	var _links = create_minimal_links(input_neurons, output_neurons)
	
	return all_neurons

static func create_input_neurons(params: Params) -> Dictionary: # Dictionary<String, Neuron>
	"""Creates a dictionary of input neurons and Bias neuron"""
	var input_neurons: Dictionary = {} # Dictionary<String, Neuron>
	
	var bias_neuron: Neuron = _create_bias_neuron(params.num_inputs)
	input_neurons[bias_neuron.neuron_id] = bias_neuron
	
	for i in range(1, params.num_inputs + 1):
		var neuron_pos = Vector2(0, float(i)/Params.num_inputs)
		var neuron_type = Enums.NEURON_TYPE.input
		
		var neuron_id =	Innovations.store_neuron(neuron_type)
		var new_neuron = Neuron.new(neuron_id,
									neuron_type,
									neuron_pos,
									Params.default_curve,
									false)
		input_neurons[neuron_id] = new_neuron
	
	return input_neurons

static func create_output_neurons(params: Params) -> Dictionary: # Dictionary<String, Neuron>
	var output_neurons: Dictionary = {} # Dictionary<String, Neuron>
	
	var output_count = params.num_outputs
	for i in output_count:
		var new_pos = Vector2(1, float(i)/output_count)
		var neuron_id = Innovations.store_neuron(Enums.NEURON_TYPE.output)
		var new_neuron = Neuron.new(neuron_id,
									Enums.NEURON_TYPE.output,
									new_pos,
									Params.default_curve,
									false)
		output_neurons[neuron_id] = new_neuron
	
	return output_neurons

static func _create_bias_neuron(input_count: int) -> Neuron:
	var neuron_type = Enums.NEURON_TYPE.bias
	var neuron_pos: Vector2 = Vector2(0, 1/input_count)
	
	var neuron_id = Innovations.store_neuron(neuron_type)
	
	var bias_neuron: Neuron = Neuron.new(neuron_id,
									neuron_type,
									neuron_pos,
									Params.default_curve,
									false)
	return bias_neuron
	
static func create_minimal_links(input_neurons: Dictionary, output_neurons: Dictionary) -> Dictionary: 
	var links_added: int = 0
	var genome_links: Dictionary = {}
	while links_added < Params.num_initial_links:
		var from_neuron_id = Util.random_choice(input_neurons.keys())
		var to_neuron_id = Util.random_choice(output_neurons.keys())
		
		if input_neurons[from_neuron_id].neuron_type == Enums.NEURON_TYPE.bias:
			continue # don't add a link that connects from a bias neuron in the first gen
		
		var innov_id: int = Innovations.check_new_link(from_neuron_id, to_neuron_id)

		if not genome_links.has(innov_id):
			var new_link = Link.new(innov_id,
										Util.gauss(Params.w_range),
										false,
										from_neuron_id,
										to_neuron_id)
			genome_links[innov_id] = new_link
			links_added += 1
	
	return genome_links
