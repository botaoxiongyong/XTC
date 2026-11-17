import json
from pathlib import Path
import tempfile
import unittest
from core import Curve, Project, demo, validate_ties, transform, correlated_points

class CoreTests(unittest.TestCase):
    def test_linear_mapping_and_boundaries(self):
        ties=[[0,10,0],[5,20,1],[10,50,0]]
        self.assertEqual(transform(2.5,ties),15)
        self.assertEqual(transform(7.5,ties),35)
        self.assertEqual(transform(10,ties),50)
        self.assertIsNone(transform(-1,ties))
        self.assertEqual(transform(-1,ties,True),8)
    def test_invalid_models(self):
        for ties in ([[0,0,0],[0,1,0]], [[0,2,0],[1,1,0]], [[0,0,2]], [[float('nan'),0,0]]):
            with self.assertRaises(ValueError): validate_ties(ties)
        with self.assertRaises(ValueError): transform(1,[[0,0,0]])
    def test_project_roundtrip_and_export(self):
        with tempfile.TemporaryDirectory() as d:
            path=Path(d)/'project.json'; project=demo(); project.save(path)
            self.assertEqual(Project.load(path),project)
            points=correlated_points(project.records[0],project.ties[0])
            self.assertEqual(points[0][0],8); self.assertEqual(points[-1][0],88)
            path.write_text(json.dumps({'format':'other','version':1}))
            with self.assertRaises(ValueError): Project.load(path)
    def test_column_import_and_errors(self):
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/'curve.dat'; p.write_text('# comment\n2,20,200\n1,10,100\n')
            self.assertEqual(Curve.load(p,1,3).points,[[1,100],[2,200]])
            p.write_text('0 1\n0 2\n')
            self.assertEqual(Curve.load(p).points, [[0,1],[0,2]])
            p.write_text('0 1\n1 nan\n')
            with self.assertRaises(ValueError): Curve.load(p)

if __name__=='__main__': unittest.main()
