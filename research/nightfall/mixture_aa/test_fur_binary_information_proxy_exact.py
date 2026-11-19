import unittest
from fractions import Fraction as Q
from fur_binary_information_proxy_exact import audit, proxy


class BinaryInformationProxyTests(unittest.TestCase):
    def test_random_posteriors_exact(self):
        receipt=audit()
        self.assertEqual(receipt["status"],"pass")
        self.assertEqual(receipt["random_posteriors"],24)
        self.assertFalse(receipt["pinsker_proved_here"])

    def test_zero_probability_atoms(self):
        p=proxy((Q(1,3),Q(2,3)),((Q(0),Q(1)),(Q(1),Q(0))))
        self.assertEqual(p["coords"][0]["shared_seed_mismatch"],"4/9")
        self.assertEqual(p["coords"][0]["exact_variance_pair_identity"],"4/9")

    def test_identical_components_zero_information_proxy(self):
        p=proxy((Q(1,2),Q(1,2)),((Q(1,3),Q(2,3)),(Q(1,3),Q(2,3))))
        self.assertTrue(all(Q(z["shared_seed_mismatch"])==0 for z in p["coords"]))

    def test_invalid_weights_fail(self):
        with self.assertRaisesRegex(ValueError,"normalized"):
            proxy((Q(1),Q(1)),((Q(0),),(Q(1),)))

    def test_invalid_biases_fail(self):
        with self.assertRaisesRegex(ValueError,"biases"):
            proxy((Q(1),),((Q(2),),))


if __name__=="__main__":
    unittest.main()
