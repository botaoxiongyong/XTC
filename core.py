"""Portable data model for XTC Python. No GUI or third-party dependencies."""
from dataclasses import dataclass, field, asdict
from bisect import bisect_right
import json
import math
from pathlib import Path


def read_rows(path, columns=2):
    rows = []
    for number, line in enumerate(Path(path).read_text(encoding='utf-8-sig').splitlines(), 1):
        line = line.split('#', 1)[0].strip()
        if not line:
            continue
        try:
            row = [float(v) for v in line.replace(',', ' ').split()]
        except ValueError as exc:
            raise ValueError(f'Line {number}: expected numeric columns (use # for comments).') from exc
        if len(row) < columns or not all(math.isfinite(v) for v in row):
            raise ValueError(f'Line {number}: expected at least {columns} finite numbers.')
        rows.append(row)
    if len(rows) < 2:
        raise ValueError('At least two data rows are required.')
    return rows


@dataclass
class Curve:
    name: str
    points: list
    source: str = ''

    @classmethod
    def load(cls, path, xcol=1, ycol=2):
        if min(xcol, ycol) < 1 or xcol == ycol:
            raise ValueError('Choose distinct column numbers starting at 1.')
        rows = read_rows(path, max(xcol, ycol))
        points = sorted([[r[xcol-1], r[ycol-1]] for r in rows], key=lambda p: p[0])
        return cls(Path(path).stem, points, str(Path(path).resolve()))


@dataclass
class Project:
    reference: Curve | None = None
    records: list = field(default_factory=list)
    ties: list = field(default_factory=list)

    def to_dict(self):
        return asdict(self)

    @classmethod
    def from_dict(cls, obj):
        reference = Curve(**obj['reference']) if obj.get('reference') else None
        records = [Curve(**r) for r in obj.get('records', [])]
        ties = obj.get('ties', [[] for _ in records])
        if len(records) != len(ties):
            raise ValueError('Project record and tie-point counts differ.')
        for curve in ([reference] if reference else []) + records:
            if len(curve.points) < 2 or any(len(p) != 2 or not all(math.isfinite(v) for v in p) for p in curve.points):
                raise ValueError('Invalid curve data in project.')
            if any(a[0] > b[0] for a,b in zip(curve.points, curve.points[1:])):
                raise ValueError('Curve coordinates must be nondecreasing.')
        ties = [validate_ties(t) for t in ties]
        return cls(reference, records, ties)

    def save(self, path):
        target = Path(path)
        temporary = target.with_suffix(target.suffix + '.tmp')
        temporary.write_text(json.dumps({'format': 'xtc-python', 'version': 1, 'project': self.to_dict()}, indent=2), encoding='utf-8')
        temporary.replace(target)

    @classmethod
    def load(cls, path):
        obj = json.loads(Path(path).read_text(encoding='utf-8'))
        if obj.get('format') != 'xtc-python' or obj.get('version') != 1:
            raise ValueError('Unsupported project format/version.')
        return cls.from_dict(obj['project'])


def validate_ties(ties):
    result = sorted([list(t) for t in ties])
    for t in result:
        if len(t) != 3 or not all(math.isfinite(v) for v in t) or t[2] not in (0, 1):
            raise ValueError('Tie points require source, target, and protection (0 or 1).')
    if any(a[0] >= b[0] or a[1] >= b[1] for a,b in zip(result, result[1:])):
        raise ValueError('Source and target coordinates must both increase; ties cannot cross.')
    return result


def transform(x, ties, extrapolate=False):
    """Piecewise linear mapping; outside tie range is excluded by default."""
    ties = validate_ties(ties)
    if len(ties) < 2:
        raise ValueError('At least two tie points are required for correlation.')
    if not extrapolate and not ties[0][0] <= x <= ties[-1][0]:
        return None
    i = max(0, min(len(ties)-2, bisect_right([t[0] for t in ties], x)-1))
    a, b = ties[i:i+2]
    return a[1] + (x-a[0]) * (b[1]-a[1]) / (b[0]-a[0])


def correlated_points(curve, ties, extrapolate=False):
    ties = validate_ties(ties)
    if len(ties) < 2:
        raise ValueError('At least two tie points are required for correlation.')
    result = []
    coordinates = [t[0] for t in ties]
    for x,y in curve.points:
        if not extrapolate and not ties[0][0] <= x <= ties[-1][0]:
            continue
        i = max(0, min(len(ties)-2, bisect_right(coordinates, x)-1))
        a,b = ties[i:i+2]
        mapped = a[1] + (x-a[0]) * (b[1]-a[1]) / (b[0]-a[0])
        result.append([mapped, y])
    return result


def demo():
    xs = [i/5 for i in range(501)]
    signal = lambda x: math.sin(x/5) + .35*math.sin(x/1.8)
    return Project(Curve('Reference (synthetic)', [[x,signal(x)] for x in xs]),
                   [Curve('Core A (synthetic)', [[x,signal(x*.8+8)] for x in xs])],
                   [[[0,8,0],[50,48,0],[100,88,0]]])
