import unittest
from grade_correlated_influence import evaluate

def diagonal(n=8, noise="1/50000"):
    from fractions import Fraction as F
    w=str((1-F(noise))/2)
    return {"n":n,"components":[
        {"weight":w,"p":["0"]*n},
        {"weight":w,"p":["1"]*n},
        {"weight":noise,"p":["1/2"]*n}],
        "linear_coefficients":["1"]+["0"]*(n-1)}

class CorrelatedInfluenceTests(unittest.TestCase):
    def test_valid_exact_witness(self):
        self.assertTrue(evaluate(diagonal())["valid"])
    def test_product_law_does_not_pass(self):
        x=diagonal()
        x["components"]=[{"weight":"1/2","p":["1/2"]*8},
                         {"weight":"1/2","p":["1/2"]*8}]
        self.assertFalse(evaluate(x)["valid"])
    def test_zero_support_rejected(self):
        x=diagonal(); x["components"]=x["components"][:2]
        x["components"][0]["weight"]="1/2";x["components"][1]["weight"]="1/2"
        with self.assertRaises(ValueError): evaluate(x)
    def test_bad_probability_rejected(self):
        x=diagonal(); x["components"][0]["p"][0]="2"
        with self.assertRaises(ValueError): evaluate(x)
    def test_float_rejected(self):
        x=diagonal();x["components"][0]["weight"]=0.5
        with self.assertRaises(ValueError): evaluate(x)

if __name__=="__main__":unittest.main()
