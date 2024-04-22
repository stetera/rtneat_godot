extends Node

enum NEURON_TYPE{ input, bias, hidden, output }

# Every mutation has two probabilities associated. This enum just refers to these
# two states.
enum MUTATION_RATE{normal, heightened}


# enum referring to the array indices of the data returned by check_new_split()
enum SPLIT_MEMBERS{from_link, neuron_id, to_link}
