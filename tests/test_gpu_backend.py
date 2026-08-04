import unittest

from kitness_gpu import select_backend


class BackendSelectionTests(unittest.TestCase):
    def test_selects_metal_when_the_metal_compiler_is_available(self):
        self.assertEqual(select_backend(), "metal")


if __name__ == "__main__":
    unittest.main()