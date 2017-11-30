import JSON

from draco.run import run, DRACO_LP

def list_weights():
	with open(os.path.join(os.path.dirname(__file__), "../data/weights.json")) as f:
        return JSON.load(f)

def count_violations(full_spec):
    # TODO: finish
	task = run(full_spec, files=DRACO_LP + ["count.lp"])
	return task.violations

def count_cost(violations, weights):
	# count the cost of the current full spec given weights
	pass

def solve_partial_spec(partial_spec, weights):
	# returns the best full spec with provided weights
	pass

## useful for initialization and normalization

def get_grounding_num(full_spec):
	# returns the number of groudings for each soft constraint
	# return in a dictionary
	pass

## todo later, for MC-SAT (sampling)

def get_soft_constraint(constraint_id):
	# returns the weight and the constraint text given its id
	pass

def sample_full_spec(partial_spec, extra_hard_constraints):
	# sample a solution by solving partial_spec
	# using original hard_constraints plus extra ones (extra_hard_constraints)
	pass