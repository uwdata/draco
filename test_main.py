from z3 import *

def test_z3():
    x = Real('x')
    y = Real('y')
    s = Solver()
    s.add(x + y > 5, x > 1, y > 1)
    assert d.check() == sat
    print(s.model())
