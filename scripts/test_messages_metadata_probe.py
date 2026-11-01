"""Offline probe regressions; uses the host's /bin/bash, including macOS Bash 3.2."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).with_name("probe_messages_appintents.sh")

class MetadataProbeTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        for name in ("xcodebuild", "xcrun", "xcode-select"):
            tool = self.bin / name
            tool.write_text("#!/bin/sh\nprintf '%s\\n' fixture-sdk\n")
            tool.chmod(0o755)
        self.env = {**os.environ, "PATH": str(self.bin) + os.pathsep + os.environ["PATH"]}

    def metadata(self, nested=False):
        path = self.root / "Runtime With Spaces" / "Messages.app"
        if nested:
            path /= "Contents/Resources"
        path /= "Metadata.appintents/extract.actionsdata"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps({"entities": {"MessageEntity": {}}, "queries": {}, "actions": {}}))
        return path

    def run_probe(self, *roots):
        return subprocess.run(["/bin/bash", str(SCRIPT), *(str(p) for p in roots)],
                              text=True, capture_output=True, env=self.env, timeout=20)

    def test_direct_metadata_path_and_spaces(self):
        self.metadata()
        result = self.run_probe(self.root)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Metadata files: 1", result.stdout)
        self.assertIn("MessageEntity", result.stdout)

    def test_nested_metadata_path(self):
        self.metadata(nested=True)
        result = self.run_probe(self.root)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Metadata files: 1", result.stdout)

    def test_duplicate_roots_do_not_duplicate_metadata(self):
        self.metadata()
        result = self.run_probe(self.root, self.root)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Metadata files: 1", result.stdout)

    def test_missing_metadata_is_an_explicit_failure(self):
        result = self.run_probe(self.root)
        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertIn("No Messages AppIntents metadata", result.stderr)

if __name__ == "__main__":
    unittest.main()
