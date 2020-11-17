import unittest

import numpy as np

class TestMethods(unittest.TestCase):
    def test_pytorch(self):
        size = 10
        x = np.random.randint(2, size=size)
        self.assertEqual(len(x), size)

if __name__ == '__main__':
    unittest.main()
