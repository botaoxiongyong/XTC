"""Validate a draft and write the original XTC project and axis formats."""
from collections import Counter
from dataclasses import dataclass, field
import math
from pathlib import Path

from core import Curve, validate_ties
from legacy import CORE_NAME_COMMENT, read_numeric_rows
from workspace import Workspace
from yrr import YRange, axis_row


@dataclass(frozen=True)
class CurveFile:
    path: Path
    count: int = 2
    x: int = 1
    y: int = 2


@dataclass
class Parameter:
    name: str
    reference_name: str = ''
    reference: CurveFile | None = None


@dataclass
class Core:
    name: str
    age_file: Path | None = None
    initial_ties: list | None = None
    tephra: Path | None = None
    disturbance: Path | None = None
    curves: dict[int, CurveFile] = field(default_factory=dict)


def detect_columns(path):
    widths = Counter(map(len, read_numeric_rows(path, [])))
    if not widths or widths.most_common(1)[0][0] < 2:
        raise ValueError(f'{path.name}: requires at least two numeric columns.')
    return widths.most_common(1)[0][0]


def create_project(path, parameters, cores):
    """Create the project last, after its sidecar and any requested initial age files."""
    path = path.expanduser().resolve()
    if path.suffix.lower() != '.xtci':
        path = path.with_suffix('.xtci')
    if not path.parent.is_dir():
        raise ValueError('Choose an existing project folder.')
    if not parameters or not cores:
        raise ValueError('Add at least one parameter and one core.')
    records = 1 + len(cores)
    styles = path.with_name(path.name + '.yrr')
    output = {}
    numeric = {}
    default = YRange()

    def relative(file, existing=True):
        file = file.expanduser().resolve()
        if not file.is_relative_to(path.parent):
            raise ValueError(f'{file.name}: choose a file inside the project folder or its subfolders.')
        name = file.relative_to(path.parent).as_posix()
        if name == 'NO_DATA' or any(char.isspace() for char in name) or '\\' in name:
            raise ValueError(f'{name}: use a relative filename without spaces or backslashes.')
        if existing and not file.is_file():
            raise ValueError(f'{name}: file does not exist.')
        return name

    def rows(file):
        file = file.resolve()
        if file not in numeric:
            numeric[file] = read_numeric_rows(file, [])
        return numeric[file]

    def label(text, fallback=''):
        text = text.strip() or fallback
        if not text or any(char in text for char in '\r\n\\'):
            raise ValueError('Enter a name without line breaks or backslashes.')
        return text

    def curve_entry(spec, reference=False):
        if spec is None:
            return 'FP NO_DATA', axis_row(default, (1, 2), 'NO_DATA  2  1  2')
        name = relative(spec.path)
        if spec.x == spec.y or not (1 <= spec.x <= spec.count and 1 <= spec.y <= spec.count):
            raise ValueError(f'{name}: choose distinct X and Y columns within the total column count.')
        source = rows(spec.path)
        if len(source) < 2 or any(len(row) != spec.count for row in source):
            raise ValueError(f'{name}: expected at least two rows with {spec.count} numeric columns each.')
        points = [[row[spec.x - 1], row[spec.y - 1]] for row in source]
        if min(p[0] for p in points) == max(p[0] for p in points):
            raise ValueError(f'{name}: the X column must contain at least two different coordinates.')
        columns = f'{spec.count}  {spec.x}  {spec.y}'
        suffix = 'R' if reference else 'P'
        directive = (f'F{suffix} {name}' if (spec.count, spec.x, spec.y) == (2, 1, 2)
                     else f'G{suffix} {name}  {columns}')
        limits = Workspace.axis_limits(Curve(name, points), default)
        return directive, axis_row(default, limits, f'{name}  {columns}')

    lines = [f'NDS {records:2d} NPC {len(parameters):2d}']
    reference_entries = []
    for parameter in parameters:
        if parameter.reference is None:
            raise ValueError(f'{parameter.name}: choose a reference file.')
        reference_name = label(parameter.reference_name, parameter.reference.path.stem)
        lines.append(f'CR {reference_name} \\')
        reference_entries.append(curve_entry(parameter.reference, reference=True))
    lines.extend(f'CP {label(parameter.name)} \\' for parameter in parameters)
    lines.extend(directive for directive, _ in reference_entries)

    core_entries = []
    for index, core in enumerate(cores):
        if core.age_file is None:
            raise ValueError(f'{core.name}: choose an age file or create an initial model.')
        if not core.curves:
            raise ValueError(f'{core.name}: assign at least one parameter file.')
        age = relative(core.age_file, existing=core.initial_ties is None)
        lines.append(f'{CORE_NAME_COMMENT}{index} {label(core.name)}')
        lines.append(f'FC {age}')
        if core.initial_ties is None:
            age_rows = rows(core.age_file)
            if not all(2 <= len(row) <= 3 for row in age_rows):
                raise ValueError(f'{age}: expected depth, target and optional protection flag.')
            ties = validate_ties([row if len(row) == 3 else row + [0] for row in age_rows])
        else:
            ties = validate_ties(core.initial_ties)
            destination = path.parent / age
            if destination in output or destination in (path, styles):
                raise ValueError(f'{age}: choose a distinct filename for the new age model.')
            if not destination.parent.is_dir():
                raise ValueError(f'{age}: the age-file folder does not exist.')
            output[destination] = ''.join(f'{x:.17g}  {target:.17g}  0.0\n'
                                           for x, target, _ in ties).encode()
        if len(ties) < 2:
            raise ValueError(f'{age}: an age model needs at least two tie points.')
        for code, file in (('FT', core.tephra), ('FD', core.disturbance)):
            if file is not None:
                lines.append(f'{code} {relative(file)}')
        entries = [curve_entry(core.curves.get(column)) for column in range(len(parameters))]
        core_entries.append(entries)
        lines.extend(directive for directive, _ in entries)

    axis_lines = [f'NDS = {records:2d} NPC = {len(parameters):2d}']
    for column, (_, reference_axis) in enumerate(reference_entries):
        axis_lines.append(reference_axis)
        axis_lines.extend(entries[column][1] for entries in core_entries)
    output[styles] = ('\n'.join(axis_lines) + '\n').encode()
    output[path] = ('\n'.join(lines) + '\n').encode()
    for file in output:
        if file.exists() or file.is_symlink():
            raise ValueError(f'{file.name} already exists. Choose a new filename.')
    created = []
    try:
        for file, contents in output.items():
            with file.open('xb') as handle:
                created.append(file)
                handle.write(contents)
    except OSError:
        for file in reversed(created):
            file.unlink()
        raise
    return path
