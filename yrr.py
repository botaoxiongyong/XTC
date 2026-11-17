"""Read and update XTC Y-axis settings in parameter-major order."""
from dataclasses import dataclass
import math
import os
from pathlib import Path
import re
import stat
import tempfile


@dataclass(frozen=True)
class YRange:
    lower: float | None = None
    upper: float | None = None
    logarithmic: bool = False
    inverted: bool = False


def parse_yrr(data, records, parameters):
    lines = data.decode('utf-8-sig').splitlines()
    header = re.fullmatch(r'NDS\s*=\s*(\d+)\s+NPC\s*=\s*(\d+)\s*', lines[0] if lines else '')
    if not header or tuple(map(int, header.groups())) != (records, parameters):
        raise ValueError('YRR dimensions do not match the project.')
    if len(lines) < 1 + records * parameters:
        raise ValueError('YRR file is missing axis rows.')
    settings = {}
    for index, line in enumerate(lines[1:1 + records * parameters]):
        fields = line.split()
        if len(fields) < 4 or fields[0] not in ('N', 'G') or fields[1] not in ('-', 'I'):
            raise ValueError(f'Invalid YRR axis row on line {index + 2}.')
        lower, upper = map(float, fields[2:4])
        if not math.isfinite(lower) or not math.isfinite(upper):
            raise ValueError(f'Nonfinite YRR limit on line {index + 2}.')
        automatic = line.partition('# XTC-Python auto=')[2].strip()
        if lower >= upper:
            lower = upper = None
        settings[divmod(index, records)] = YRange(
            None if 'min' in automatic else lower,
            None if 'max' in automatic else upper,
            fields[0] == 'G', fields[1] == 'I',
        )
    return lines, settings


def axis_row(setting, limits, columns):
    lower, upper = limits
    mode = 'G' if setting.logarithmic else 'N'
    direction = 'I' if setting.inverted else '-'
    auto = [name for name, value in (('min', setting.lower), ('max', setting.upper)) if value is None]
    suffix = ' # XTC-Python auto=' + ','.join(auto) if auto else ''
    return f'{mode} {direction} {lower:+.16e} {upper:+.16e}  {columns}{suffix}'


def write_atomic(path, data):
    path = Path(path)
    with tempfile.NamedTemporaryFile(dir=path.parent, prefix=f'.{path.name}.', delete=False) as file:
        temporary = Path(file.name)
        try:
            file.write(data)
            file.close()
            if path.exists():
                temporary.chmod(stat.S_IMODE(path.stat().st_mode))
            os.replace(temporary, path)
        finally:
            temporary.unlink(missing_ok=True)
