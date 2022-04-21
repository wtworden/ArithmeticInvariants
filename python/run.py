from sys import argv
from time import time
import pickle
import hpc_function

import os
cwd = os.path.dirname(os.path.realpath(__file__))

script, name, prec, deg = argv

start = time()

d = hpc_function.compute_trace_field(name,int(prec),int(deg))

end = time()

if d != None:
    p = pickle.dumps(d)
    with open(os.path.join(cwd,'{}/{}'.format(name,name)), 'bw') as pfile:
        pfile.write(d)
    

print('name: {}; time: {}'.format(name, end-start))


