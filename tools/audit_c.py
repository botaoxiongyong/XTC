"""Inventory every C function definition, declaration, call and menu string."""
import argparse,json,re
from pathlib import Path
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('source', type=Path)
source = parser.parse_args().source
text = source.read_text()
def blank(match): return ''.join('\n' if c=='\n' else ' ' for c in match[0])
clean=re.sub(r'/\*.*?\*/|//[^\n]*',blank,text,flags=re.S)
# Preserve line numbers while removing strings before scanning bodies for calls.
pattern=re.compile(r'^\s*(?:int|void|float|double)\s+([A-Za-z_]\w*)\s*\(([^;{}]*)\)\s*\{',re.M)
functions=[]
for match in pattern.finditer(clean):
    depth=1; i=match.end()
    scanned=re.sub(r'"(?:\\.|[^"\\])*"',blank,clean)
    while i<len(scanned) and depth:
        depth+=(scanned[i]=='{')-(scanned[i]=='}'); i+=1
    line=text.count('\n',0,match.start(1))+1
    while text.splitlines()[line-1].strip()=='': line+=1
    body=scanned[match.end():i]
    calls=sorted(set(re.findall(r'\b([A-Za-z_]\w*)\s*\(',body))-{'if','for','while','switch','sizeof','return'})
    functions.append({'name':match[1],'line':line,'end_line':text.count('\n',0,i)+1,'calls':calls})
declarations=sorted(set(re.findall(r'^\s*(?:int|void|float|double)\s+(\w+)\s*\([^;{}]*\)\s*;',clean,re.M)))
names={f['name'] for f in functions}
menu=sorted(set(s.replace('\\0','').strip() for s in re.findall(r'"([^"\n]*(?: : | :|: )[^"]*)"',text) if len(s)<180))
report={'source':source.name,'function_count':len(functions),'functions':functions,'declarations_without_definition':sorted(set(declarations)-names),'includes':re.findall(r'^#include\s+[<"]([^>"\n]+)',text,re.M),'calls_not_defined_in_this_file':sorted(set(c for f in functions for c in f['calls'])-names),'menu_strings':menu}
root=Path(__file__).resolve().parents[1]
(root/'docs/c_inventory.json').write_text(json.dumps(report,indent=2))
print(len(functions),'definitions;',len(report['calls_not_defined_in_this_file']),'external call names')
