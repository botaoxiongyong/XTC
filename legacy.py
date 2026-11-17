"""Read-only import of the legacy XTC core/parameter matrix."""
from pathlib import Path
import math
from core import Curve, Project, validate_ties

CORE_NAME_COMMENT = '# XTC-Python core-name '

class LegacyProject:
    def __init__(self, path):
        self.path=Path(path).resolve(); self.root=self.path.parent
        self.parameters=[]; self.references=[]; self.reference_columns=[]; self.blocks=[]; self.reference_comments=[]
        self.ancillary=[]; self.unassigned_ancillary=[]; self.warnings=[]; self.cache={}; self.core_names={}
        allowed={'NDS','CR','CP','FR','GR','FC','GC','FP','GP','FT','FD'}
        for number,line in enumerate(self.path.read_text().splitlines(),1):
            if line.startswith(CORE_NAME_COMMENT):
                index, label = line[len(CORE_NAME_COMMENT):].split(maxsplit=1)
                self.core_names[int(index)] = label
            parts=line.split()
            if not parts or parts[0].startswith('#'): continue
            code=parts[0]
            if code not in allowed: raise ValueError(f'Unsupported project directive {code}, line {number}.')
            if code=='NDS': self.nds=int(parts[1]); self.npc=int(parts[3])
            elif code=='CP': self.parameters.append(' '.join(parts[1:]).rstrip(' \\'))
            elif code=='CR': self.reference_comments.append(' '.join(parts[1:]).rstrip(' \\'))
            elif code in ('FR','GR'):
                self.references.append(self.spec(parts))
                self.reference_columns.append(self.column_count(parts))
            elif code in ('FC','GC'):
                self.blocks.append({'model':parts[1],'model_directive':code,'data':[],
                                    'columns':[],'ancillary':[]})
            elif code in ('FP','GP'):
                self.blocks[-1]['data'].append(self.spec(parts))
                self.blocks[-1]['columns'].append(self.column_count(parts))
            elif code in ('FT','FD'):
                item = {'directive': code, 'file': parts[1]}
                self.ancillary.append(item)
                if self.blocks:
                    self.blocks[-1]['ancillary'].append(item)
                else:
                    self.unassigned_ancillary.append(item)
        if len(self.parameters)!=self.npc or len(self.references)!=self.npc or len(self.blocks)!=self.nds-1 or any(len(b['data'])!=self.npc for b in self.blocks):
            raise ValueError('Project dimensions do not match NDS/NPC.')

    @staticmethod
    def column_count(parts):
        return int(parts[2]) if parts[0].startswith('G') else 2

    def spec(self,parts):
        return (parts[1],int(parts[3]),int(parts[4])) if parts[0].startswith('G') else (parts[1],1,2)

    def resolve(self,name):
        path=(self.root/name).resolve()
        if not path.is_relative_to(self.root):
            raise ValueError(f'Reference outside the authorized folder: {name}')
        return path

    def rows(self,name):
        if name in self.cache: return self.cache[name]
        self.cache[name] = read_numeric_rows(self.resolve(name), self.warnings)
        return self.cache[name]

    def curve(self,spec):
        name,x,y=spec
        if name=='NO_DATA': return None
        points=[]
        for row in self.rows(name):
            if len(row)<max(x,y): raise ValueError(f'{name}: too few columns')
            points.append([row[x-1],row[y-1]])
        points.sort(key=lambda p:p[0])
        if len(points)<2: raise ValueError(f'{name}: fewer than two points')
        duplicates=sum(a[0]==b[0] for a,b in zip(points,points[1:]))
        if duplicates: self.warnings.append(f'{name}: preserved {duplicates} repeated coordinates without averaging')
        return Curve(Path(name).stem,points,str(self.resolve(name)))

    def parameter(self,index, errors=None):
        reference=self.curve(self.references[index]); records=[]; ties=[]
        for block in self.blocks:
            try:
                curve=self.curve(block['data'][index])
            except (ValueError,OSError) as exc:
                if errors is None: raise
                errors.append(str(exc)); continue
            if curve is None: continue
            model=[row[:3] if len(row)>=3 else row[:2]+[0] for row in self.rows(block['model'])]
            ties.append(validate_ties(model)); records.append(curve)
        return Project(reference,records,ties)


def read_numeric_rows(path, warnings):
    name = path.name
    rows=[]; headers=[]
    for number,line in enumerate(path.read_text(encoding='utf-8-sig').splitlines(),1):
        text=line.split('#',1)[0].strip()
        if not text: continue
        values=[]
        for token in text.split():
            try: values.append(float(token))
            except ValueError:
                if token[0] in '+-.0123456789':
                    raise ValueError(f'{name}:{number}: malformed numeric token {token!r}')
                if values:
                    warnings.append(f'{name}:{number}: ignored trailing annotation after {len(values)} numeric columns')
                else:
                    headers.append(number)
                break
        if not values: continue
        if not all(math.isfinite(v) for v in values): raise ValueError(f'{name}:{number}: nonfinite data')
        rows.append(values)
    if headers: warnings.append(f'{name}: skipped text headings on lines {headers}')
    return rows
