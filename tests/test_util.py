from draco.util import list_weights, count_violations

def test_list_weights():
    assert "encoding_weight" in list_weights()

def test_count_violations():
    violations = count_violations({
        "mark": "bar",
        "data": {
            "url": "data/cars.csv"
        },
        "encoding": {
            "x": {
                "field": "origin",
                "type": "ordinal"
            },
            "y": {
                "field": "horsepower",
                "type": "quantitative",
                "aggregate": "mean"
            }
        }
    })

    assert "encoding" in violations
    assert violations["encoding"] == 2
