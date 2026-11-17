"""Check the valid interpolation domain against functions compiled from original C.

Out-of-range C paths are deliberately not executed: source accesses beyond its array.
"""
import ctypes,os,random,shutil,subprocess,tempfile,unittest
from pathlib import Path
from core import transform

REFERENCE_C = os.environ.get('XTC_REFERENCE_C')


@unittest.skipUnless(REFERENCE_C and Path(REFERENCE_C).is_file() and shutil.which('cc'),
                     'set XTC_REFERENCE_C and install a C compiler for the optional reference test')
class ReferenceTests(unittest.TestCase):
    def test_in_range_forward_inverse_against_c(self):
        text=Path(REFERENCE_C).read_text()
        pieces=[]
        for name in ('x_2_t','t_2_x'):
            start=text.index('int '+name+' (',text.index('void auto_scale_2 ('))
            brace=text.index('{',start); depth=1; end=brace+1
            while depth:
                depth+=(text[end]=='{')-(text[end]=='}');end+=1
            pieces.append(text[start:end])
        with tempfile.TemporaryDirectory() as folder:
            source=Path(folder)/'reference.c'; library=Path(folder)/'reference.so'
            source.write_text('\n'.join(pieces)); subprocess.run(['cc','-shared','-fPIC','-O0',str(source),'-o',str(library)],check=True,capture_output=True)
            lib=ctypes.CDLL(str(library)); fp=ctypes.POINTER(ctypes.c_float)
            for name in ('x_2_t','t_2_x'):
                func=getattr(lib,name);func.argtypes=[ctypes.c_float,fp,fp,ctypes.c_int];func.restype=ctypes.c_int
            ties=[[0,2,0],[5,8,0],[15,37,0],[30,50,0]]
            array=(ctypes.c_float*8)(*[v for tie in ties for v in tie[:2]])
            rng=random.Random(42)
            for x in [0,5,15,30]+[rng.uniform(0,30) for _ in range(100)]:
                result=ctypes.c_float(); status=lib.x_2_t(x,ctypes.byref(result),array,4)
                self.assertEqual(status,1)
                self.assertAlmostEqual(result.value,transform(x,ties),delta=1e-5)
                inverse=ctypes.c_float(); status=lib.t_2_x(result,ctypes.byref(inverse),array,4)
                self.assertEqual(status,1); self.assertAlmostEqual(inverse.value,x,delta=1e-5)
