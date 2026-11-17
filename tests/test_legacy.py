import tempfile
from pathlib import Path
import unittest
from legacy import LegacyProject

class LegacyTests(unittest.TestCase):
    def test_import_preserves_steps_annotations_protection_and_rejects_malformed(self):
        with tempfile.TemporaryDirectory() as folder:
            root=Path(folder)
            (root/'test.xtci').write_text('NDS 2 NPC 1\nCR Ref \\\nCP Lithology \\\nFR ref.dat\nGC ties.dat\nFP source.dat\n')
            (root/'ref.dat').write_text('0 1\n1 2\n')
            (root/'ties.dat').write_text('0 0 1\n10 1 0\n')
            (root/'source.dat').write_text('Depth Value\n0 1\n5 2 annotation\n5 3\n10 4\n')
            legacy=LegacyProject(root/'test.xtci'); project=legacy.parameter(0)
            self.assertEqual(project.records[0].points,[[0,1],[5,2],[5,3],[10,4]])
            self.assertEqual(project.ties[0][0],[0,0,1])
            self.assertTrue(any('annotation' in w for w in legacy.warnings))
            (root/'source.dat').write_text('0 1\n10.0. 2\n')
            with self.assertRaisesRegex(ValueError,'malformed numeric'): LegacyProject(root/'test.xtci').parameter(0)
    def test_reference_cannot_escape_archive(self):
        with tempfile.TemporaryDirectory() as folder:
            p=Path(folder)/'test.xtci'
            p.write_text('NDS 1 NPC 1\nCP test \\\nFR ../outside.dat\n')
            legacy=LegacyProject(p)
            with self.assertRaisesRegex(ValueError,'outside'): legacy.parameter(0)
