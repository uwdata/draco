#script(python)

class Observer:
    def __init__(self):
        self.minimize_literals = []

    def minimize(self, priority, literals):
        self.minimize_literals = literals

def main(prg):
    assert(prg.configuration.solve.opt_mode == 'optN'), 'Set --opt-mode=OptN.'

    with prg.backend() as backend:
        # Use model count as number of models to output
        count = int(prg.configuration.solve.models)

        # register observer
        obs = Observer()
        prg.register_observer(obs)

        prg.ground([('base', [])])

        while count > 0:
            cost = 0

            prg.configuration.solve.models = count
            with prg.solve(yield_=True) as handle:
                if handle.get().unsatisfiable:
                    break
                for model in handle:
                    if model.optimality_proven:
                        cost = model.cost[0]
                        count -= 1

            if count > 0:
                aux = backend.add_atom()
                backend.add_weight_rule([aux], cost+1, obs.minimize_literals)
                backend.add_rule([], [-aux])
#end.
