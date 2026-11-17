"""Validate a draft and write the original XTC project and axis formats."""
from collections import Counter
from dataclasses import dataclass, field
import json
import math
from pathlib import Path

from core import Curve, validate_ties
from legacy import CORE_NAME_COMMENT, read_numeric_rows
from workspace import MODEL_COMMENT, TIE_COMMENT, Workspace
from yrr import YRange, axis_row, parse_yrr, write_atomic


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


def load_project_draft(workspace):
    """Build an editable copy of the project matrix and file assignments."""
    legacy = workspace.legacy

    def curve(spec, columns):
        name, x, y = spec
        return None if name == 'NO_DATA' else CurveFile(legacy.root / name, columns, x, y)

    parameters = [
        Parameter(name, legacy.reference_comments[index] if index < len(legacy.reference_comments) else '',
                  curve(legacy.references[index], legacy.reference_columns[index]))
        for index, name in enumerate(legacy.parameters)
    ]
    cores = []
    for index, block in enumerate(legacy.blocks):
        core = Core(workspace.core_names[index], age_file=legacy.root / block['model'])
        for code, attr in (('FT', 'tephra'), ('FD', 'disturbance')):
            name = next((item['file'] for item in block['ancillary'] if item['directive'] == code), None)
            if name is not None:
                setattr(core, attr, legacy.root / name)
        for column, (spec, count) in enumerate(zip(block['data'], block['columns'])):
            selection = curve(spec, count)
            if selection is not None:
                core.curves[column] = selection
        cores.append(core)
    return parameters, cores


def create_project(path, parameters, cores):
    path = path.expanduser().resolve()
    if path.suffix.lower() != '.xtci':
        path = path.with_suffix('.xtci')
    output = project_files(path, parameters, cores)
    write_project_files(output)
    return path


def save_project_definition(workspace, parameters, cores):
    """Update the open project's definition while preserving existing age models."""
    original_parameters, original_cores = load_project_draft(workspace)
    if parameters == original_parameters and cores == original_cores:
        return workspace.path
    if workspace.style_error:
        raise ValueError(workspace.style_error)
    prior_files = {workspace.path: workspace.project_bytes}
    if workspace.original_style_bytes is not None:
        prior_files[workspace.style_path] = workspace.original_style_bytes
    output = project_files(workspace.path, parameters, cores, workspace,
                           original_parameters, original_cores)
    write_project_files(output, prior_files)
    return workspace.path


def project_files(path, parameters, cores, workspace=None, original_parameters=(), original_cores=()):
    """Render matching project and YRR matrices before touching the filesystem."""
    if not path.parent.is_dir():
        raise ValueError('Choose an existing project folder.')
    if not parameters or not cores:
        raise ValueError('Add at least one parameter and one core.')
    records = 1 + len(cores)
    styles = path.with_name(path.name + '.yrr')
    output = {}
    numeric = {}
    default = YRange()
    old_axis_lines = []
    if workspace is not None and workspace.style_bytes is not None:
        old_axis_lines, _ = parse_yrr(workspace.style_bytes, workspace.legacy.nds, workspace.legacy.npc)

    def relative(file, existing=True):
        file = file.expanduser().absolute()
        if not file.is_relative_to(path.parent) or not file.resolve().is_relative_to(path.parent):
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

    def curve_entry(spec, row, column):
        reference = row == 0
        unchanged = column < len(original_parameters) and row <= len(original_cores)
        if unchanged:
            original = (original_parameters[column].reference if reference
                        else original_cores[row - 1].curves.get(column))
            unchanged = spec == original
        old_axis = (old_axis_lines[1 + column * workspace.legacy.nds + row]
                    if unchanged and old_axis_lines else None)
        suffix = 'R' if reference else 'P'
        if spec is None:
            return f'F{suffix} NO_DATA', old_axis or axis_row(default, (1, 2), 'NO_DATA  2  1  2')
        name = relative(spec.path, existing=not unchanged)
        columns = f'{spec.count}  {spec.x}  {spec.y}'
        directive = (f'F{suffix} {name}' if (spec.count, spec.x, spec.y) == (2, 1, 2)
                     else f'G{suffix} {name}  {columns}')
        if unchanged:
            if old_axis is not None:
                return directive, old_axis
            limits = Workspace.axis_limits(workspace.curve_at(column, row), default)
            return directive, axis_row(default, limits, f'{name}  {columns}')
        if spec.x == spec.y or not (1 <= spec.x <= spec.count and 1 <= spec.y <= spec.count):
            raise ValueError(f'{name}: choose distinct X and Y columns within the total column count.')
        source = rows(spec.path)
        if len(source) < 2 or any(len(row) != spec.count for row in source):
            raise ValueError(f'{name}: expected at least two rows with {spec.count} numeric columns each.')
        points = [[row[spec.x - 1], row[spec.y - 1]] for row in source]
        if min(p[0] for p in points) == max(p[0] for p in points):
            raise ValueError(f'{name}: the X column must contain at least two different coordinates.')
        limits = Workspace.axis_limits(Curve(name, points), default)
        return directive, axis_row(default, limits, f'{name}  {columns}')

    lines = [f'NDS {records:2d} NPC {len(parameters):2d}']
    reference_entries = []
    for column, parameter in enumerate(parameters):
        had_no_reference = (column < len(original_parameters)
                            and original_parameters[column].reference is None)
        if parameter.reference is None and not had_no_reference:
            raise ValueError(f'{parameter.name}: choose a reference file.')
        fallback = parameter.reference.path.stem if parameter.reference else 'Reference'
        reference_name = label(parameter.reference_name, fallback)
        lines.append(f'CR {reference_name} \\')
        reference_entries.append(curve_entry(parameter.reference, 0, column))
    lines.extend(f'CP {label(parameter.name)} \\' for parameter in parameters)
    lines.extend(directive for directive, _ in reference_entries)
    if workspace is not None:
        lines.extend(f"{item['directive']} {item['file']}" for item in workspace.legacy.unassigned_ancillary)

    core_entries = []
    unchanged_models = set()
    for index, core in enumerate(cores):
        original_core = original_cores[index] if index < len(original_cores) else None
        unchanged_age = (original_core is not None and core.age_file == original_core.age_file
                         and core.initial_ties is None)
        if core.age_file is None:
            raise ValueError(f'{core.name}: choose an age file or create an initial model.')
        if not core.curves and (original_core is None or original_core.curves):
            raise ValueError(f'{core.name}: assign at least one parameter file.')
        age = relative(core.age_file, existing=core.initial_ties is None and not unchanged_age)
        lines.append(f'{CORE_NAME_COMMENT}{index} {label(core.name)}')
        directive = workspace.legacy.blocks[index]['model_directive'] if unchanged_age else 'FC'
        lines.append(f'{directive} {age}')
        if unchanged_age:
            unchanged_models.add(index)
        elif core.initial_ties is None:
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
        if not unchanged_age and len(ties) < 2:
            raise ValueError(f'{age}: an age model needs at least two tie points.')
        for code, attr in (('FT', 'tephra'), ('FD', 'disturbance')):
            file = getattr(core, attr)
            old_file = getattr(original_core, attr) if original_core is not None else None
            if file is not None:
                lines.append(f'{code} {relative(file, existing=file != old_file)}')
            if original_core is not None:
                extra = [item['file'] for item in workspace.legacy.blocks[index]['ancillary']
                         if item['directive'] == code][1:]
                lines.extend(f'{code} {name}' for name in extra)
        entries = [curve_entry(core.curves.get(column), index + 1, column)
                   for column in range(len(parameters))]
        core_entries.append(entries)
        lines.extend(directive for directive, _ in entries)

    axis_lines = [f'NDS = {records:2d} NPC = {len(parameters):2d}']
    for column, (_, reference_axis) in enumerate(reference_entries):
        axis_lines.append(reference_axis)
        axis_lines.extend(entries[column][1] for entries in core_entries)
    if old_axis_lines:
        axis_lines.extend(old_axis_lines[1 + workspace.legacy.nds * workspace.legacy.npc:])
    if workspace is not None:
        for line in workspace.project_bytes.decode('utf-8').splitlines():
            if line.startswith(CORE_NAME_COMMENT):
                continue
            if line.startswith(MODEL_COMMENT) and int(line[len(MODEL_COMMENT):]) not in unchanged_models:
                continue
            if line.startswith(TIE_COMMENT) and json.loads(line[len(TIE_COMMENT):])[0] not in unchanged_models:
                continue
            if line.lstrip().startswith('#'):
                lines.append(line)
    output[styles] = ('\n'.join(axis_lines) + '\n').encode()
    output[path] = ('\n'.join(lines) + '\n').encode()
    return output


def write_project_files(output, prior_files=None):
    prior_files = prior_files or {}
    for file in output:
        if file in prior_files:
            if file.read_bytes() != prior_files[file]:
                raise ValueError(f'{file.name} changed on disk. Reopen the project before saving.')
        elif file.exists() or file.is_symlink():
            raise ValueError(f'{file.name} already exists. Choose a new filename.')
    written = []
    try:
        for file, contents in output.items():
            if file in prior_files:
                if contents != prior_files[file]:
                    write_atomic(file, contents)
                    written.append(file)
            else:
                with file.open('xb') as handle:
                    written.append(file)
                    handle.write(contents)
    except OSError as error:
        failed = []
        for file in reversed(written):
            try:
                if file in prior_files:
                    write_atomic(file, prior_files[file])
                else:
                    file.unlink()
            except OSError as rollback_error:
                failed.append(f'{file.name}: {rollback_error}')
        if failed:
            raise OSError(f'{error}\nCould not restore: {", ".join(failed)}') from error
        raise
