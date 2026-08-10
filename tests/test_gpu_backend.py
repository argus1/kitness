import shutil
import unittest

from kitness_gpu import backend_capabilities, select_backend


class BackendSelectionTests(unittest.TestCase):
    def test_backend_selection_returns_supported_identifier(self):
        self.assertIn(select_backend(), {"cuda", "metal", "unavailable"})

    def test_capability_contract_contains_all_backends(self):
        capabilities = backend_capabilities()
        self.assertEqual(set(capabilities.keys()), {"cuda", "metal", "rocm", "oneapi"})

        for name, info in capabilities.items():
            self.assertEqual(info["backend"], name)
            self.assertIn("available", info)
            self.assertIn("status", info)

    @unittest.skipUnless(shutil.which("nvidia-smi"), "CUDA runtime unavailable")
    def test_selects_cuda_when_nvidia_runtime_is_available(self):
        self.assertEqual(select_backend(), "cuda")

    def test_rocm_and_oneapi_report_placeholder_status(self):
        capabilities = backend_capabilities()
        self.assertFalse(capabilities["rocm"]["available"])
        self.assertEqual(capabilities["rocm"]["status"], "stub")
        self.assertFalse(capabilities["oneapi"]["available"])
        self.assertEqual(capabilities["oneapi"]["status"], "stub")


if __name__ == "__main__":
    unittest.main()