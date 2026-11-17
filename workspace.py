"""Whole legacy project: parameters share one correlation model per core."""
import copy
import json
import math
import re
import shutil
from pathlib import Path
from legacy import LegacyProject
from core import validate_ties
from yrr import YRange, axis_row, parse_yrr, write_atomic


MODEL_COMMENT = '# XTC-Python model '
TIE_COMMENT = '# XTC-Python tie '


class Workspace:
    @classmethod
    def load(cls, path):
        self=cls(); self.legacy=LegacyProject(path)
        self.path=self.legacy.path; self.parameters=self.legacy.parameters
        self.models=[]; self.references=[]; self.curves=[]; self.issues=[]
        self.core_names = [self.legacy.core_names.get(index, Path(block['model']).stem)
                           for index, block in enumerate(self.legacy.blocks)]
        self.files={}; self.auxiliary={}
        # Read every declared dependency once, including ancillary files and styles.
        self.project_bytes = self.path.read_bytes()
        text = self.project_bytes.decode('utf-8')
        for line in text.splitlines():
            tokens=line.split()
            if tokens and tokens[0] in {'FR','GR','FP','GP','FC','GC','FT','FD'} and tokens[1]!='NO_DATA':
                name=tokens[1]
                try: self.files[name]=self.legacy.resolve(name).read_bytes()
                except OSError as exc: self.issues.append(f'{name}: {exc.strerror}')
        self.style_path = self.path.with_name(self.path.name + '.yrr')
        self.style_bytes = None
        self.style_settings = {}
        self.style_error = None
        try:
            self.style_bytes = self.style_path.read_bytes()
            _, self.style_settings = parse_yrr(self.style_bytes, self.legacy.nds, self.legacy.npc)
        except FileNotFoundError:
            pass
        except (OSError, ValueError) as exc:
            self.style_error = f'{self.style_path.name}: {exc}'
            self.issues.append(self.style_error)
        self.original_style_bytes = self.style_bytes
        for item in self.legacy.ancillary:
            name=item['file']
            if name in self.files: self.auxiliary[name]=self.files[name]
        for block in self.legacy.blocks:
            try:
                rows=self.legacy.rows(block['model'])
                self.models.append(validate_ties([r[:3] if len(r)>=3 else r[:2]+[0] for r in rows]))
            except (ValueError,OSError) as exc:
                self.models.append([]); self.issues.append(str(exc))
        embedded = {}
        for line in text.splitlines():
            if line.startswith(MODEL_COMMENT):
                core = int(line[len(MODEL_COMMENT):])
                if core in embedded or not 0 <= core < len(self.models):
                    raise ValueError('Invalid embedded correlation model index.')
                embedded[core] = []
            elif line.startswith(TIE_COMMENT):
                core, tie = json.loads(line[len(TIE_COMMENT):])
                if core not in embedded:
                    raise ValueError('Embedded tie point has no model header.')
                embedded[core].append(tie)
        for core, ties in embedded.items():
            self.models[core] = validate_ties(ties)
        self.saved_models = copy.deepcopy(self.models)
        self.embedded_models = set(embedded)
        for i in range(len(self.parameters)):
            try: reference=self.legacy.curve(self.legacy.references[i])
            except (ValueError,OSError) as exc: reference=None; self.issues.append(str(exc))
            self.references.append(reference); curves=[]
            for block in self.legacy.blocks:
                try: curves.append(self.legacy.curve(block['data'][i]))
                except (ValueError,OSError) as exc: curves.append(None); self.issues.append(str(exc))
            self.curves.append(curves)
        self.issues=list(dict.fromkeys(self.issues))
        self.notes=list(dict.fromkeys(self.legacy.warnings))
        return self

    def curve_at(self, parameter, row):
        return self.references[parameter] if row == 0 else self.curves[parameter][row - 1]

    def axis_columns(self, parameter, row):
        if row == 0:
            name, x, y = self.legacy.references[parameter]
            count = self.legacy.reference_columns[parameter]
        else:
            block = self.legacy.blocks[row - 1]
            name, x, y = block['data'][parameter]
            count = block['columns'][parameter]
        return f'{name}  {count}  {x}  {y}'

    @staticmethod
    def axis_limits(curve, setting):
        values = (point[1] for point in curve.points) if curve else iter((1.0, 2.0))
        values = [value for value in values if not setting.logarithmic or value > 0]
        lower = setting.lower if setting.lower is not None else min(values, default=1.0)
        upper = setting.upper if setting.upper is not None else max(values, default=2.0)
        if lower == upper and setting.lower is None and setting.upper is None:
            if setting.logarithmic:
                lower /= 2
                upper *= 2
            else:
                padding = max(abs(lower) * .05, .5)
                lower -= padding
                upper += padding
        return lower, upper

    def save_axis(self, parameter, row, setting):
        if self.style_error:
            raise ValueError(self.style_error)
        records, parameters = self.legacy.nds, self.legacy.npc
        if self.style_bytes is not None:
            lines, _ = parse_yrr(self.style_bytes, records, parameters)
        else:
            lines = [f'NDS = {records:2d} NPC = {parameters:2d}']
            default = YRange()
            for index in range(parameters):
                for record in range(records):
                    limits = self.axis_limits(self.curve_at(index, record), default)
                    lines.append(axis_row(default, limits, self.axis_columns(index, record)))
        line_index = 1 + parameter * records + row
        limits = self.axis_limits(self.curve_at(parameter, row), setting)
        if not all(map(math.isfinite, limits)) or limits[0] >= limits[1]:
            raise ValueError('Y minimum must be smaller than Y maximum.')
        lines[line_index] = axis_row(setting, limits, self.axis_columns(parameter, row))
        updated = ('\n'.join(lines) + '\n').encode('utf-8')

        current = self.style_path.read_bytes() if self.style_path.exists() else None
        if current != self.original_style_bytes:
            raise ValueError('The .yrr file changed on disk. Reopen the project before editing.')
        write_atomic(self.style_path, updated)
        self.original_style_bytes = self.style_bytes = updated
        self.style_settings[parameter, row] = setting

    def save(self):
        """Write edited correlation models to their existing FC/GC files."""
        changed = {index for index, model in enumerate(self.models)
                   if model != self.saved_models[index]} | self.embedded_models
        if not changed:
            return 0
        if self.path.read_bytes() != self.project_bytes:
            raise ValueError('The project file changed on disk. Reopen it before saving.')

        model_files = {}
        for index, block in enumerate(self.legacy.blocks):
            name = block['model']
            model_files.setdefault(self.legacy.resolve(name), []).append((index, name))

        writes = []
        for path, entries in model_files.items():
            indices = {index for index, _ in entries}
            if not changed.intersection(indices):
                continue
            first, name = entries[0]
            ties = validate_ties(self.models[first])
            if any(self.models[index] != ties for index in indices):
                raise ValueError(f'{name}: cores sharing this age file have different tie points.')
            original = path.read_bytes()
            if original != self.files.get(name):
                raise ValueError(f'{name} changed on disk. Reopen the project before saving.')
            newline = '\r\n' if b'\r\n' in original else '\n'
            comments = [line for line in original.decode('utf-8-sig').splitlines()
                        if line.lstrip().startswith('#')]
            rows = comments + [f'{source:.17g}  {target:.17g}  {int(protected)}.0'
                               for source, target, protected in ties]
            updated = (newline.join(rows) + newline if rows else '').encode('utf-8')
            writes.append((path, entries, ties, original, updated))

        for path, entries, ties, original, updated in writes:
            if updated != original:
                write_atomic(path, updated)
            for index, name in entries:
                self.files[name] = updated
                self.saved_models[index] = copy.deepcopy(ties)

        if self.embedded_models:
            # Earlier Python releases saved overrides as project comments.
            # Remove them after the age files have been updated so they cannot mask future edits.
            lines = self.project_bytes.splitlines(keepends=True)
            prefixes = (MODEL_COMMENT.encode(), TIE_COMMENT.encode())
            cleaned = b''.join(line for line in lines if not line.startswith(prefixes))
            write_atomic(self.path, cleaned)
            self.project_bytes = cleaned
            self.embedded_models.clear()
        return len(writes)

    def export(self, path):
        """Write a self-contained legacy project copy; never write into input tree."""
        destination=Path(path).resolve()
        if destination.suffix.lower() not in ('.xtci','.xtc'):
            destination=destination.with_suffix('.xtci')
        if destination.is_relative_to(self.path.parent):
            raise ValueError('Choose a different folder for the edited project copy. The input project folder is read only.')
        assets=destination.parent/(destination.stem+'_files')
        if assets.exists():
            raise ValueError(f'{assets.name} already exists. Choose a new project name to save a fresh copy.')
        # Do not create a broken bundle when a declared dependency is missing.
        required=[]
        for line in self.path.read_text().splitlines():
            parts=line.split()
            if parts and parts[0] in {'FR','GR','FP','GP','FC','GC','FT','FD'} and parts[1]!='NO_DATA': required.append(parts[1])
        missing=set(required)-self.files.keys()
        if missing: raise ValueError('Cannot save a complete project: missing '+', '.join(sorted(missing)))
        destination.parent.mkdir(parents=True,exist_ok=True)
        assets.mkdir()
        try:
            for name,data in self.files.items():
                target=assets/name; target.parent.mkdir(parents=True,exist_ok=True); target.write_bytes(data)
            for block,model in zip(self.legacy.blocks,self.models):
                if not model: raise ValueError('Repair missing/invalid correlation models before saving.')
                (assets/block['model']).write_text(''.join(' '.join(f'{v:.17g}' for v in row)+'\n' for row in model))
            lines=[]
            for line in self.path.read_text().splitlines():
                parts=line.split()
                if parts and parts[0] in {'FR','GR','FP','GP','FC','GC','FT','FD'} and parts[1]!='NO_DATA':
                    line=re.sub(r'^(\s*\S+\s+)\S+',lambda m:m[1]+assets.name+'/'+parts[1],line,count=1)
                lines.append(line)
            # Styles reference the same filenames; preserve settings and rewrite paths.
            if self.style_bytes is not None:
                style=self.style_bytes.decode('utf-8')
                for name in sorted(self.files,key=len,reverse=True):
                    style=re.sub(r'(?<!\S)'+re.escape(name)+r'(?!\S)',lambda m:assets.name+'/'+name,style)
                Path(str(destination)+'.yrr').write_text(style)
            temporary=destination.with_suffix(destination.suffix+'.tmp')
            temporary.write_text('\n'.join(lines)+'\n'); temporary.replace(destination)
        except Exception:
            shutil.rmtree(assets)
            raise
        return destination
