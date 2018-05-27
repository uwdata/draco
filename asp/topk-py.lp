#script(python)
import clingo

def main(prg):
    assert(prg.configuration.solve.opt_mode == 'optN'), 'Set --opt-mode=OptN.'

    # Use model count as number of models to output
    count = int(prg.configuration.solve.models)

    # We need all models and will stop the search ourselves
    prg.configuration.solve.models = 0

    prg.ground([('base', [])])

    

    while count > 0:
        model_literals = []
        with prg.solve(yield_=True) as handle:
            if not handle.get().satisfiable:
                return

            for model in handle:
                if model.optimality_proven:
                    atoms = model.symbols(atoms=True)
                    literals = [prg.symbolic_atoms[clingo.Function(a.name, a.arguments)].literal for a in atoms]
                    model_literals.append(literals)

                    count -= 1
                    if count == 0:
                        # We have enough results so let's cancel the search
                        handle.cancel()
        
        # Add rules that forbid previous models
        for literals in model_literals:
            prg.backend.add_rule([], literals)
#end.
