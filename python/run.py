from sys import argv
from time import time
import pickle
import hpc_function

import os

# get the path to the directory that contains this script
cwd = os.path.dirname(os.path.realpath(__file__))

script, name, prec, deg = argv

start = time()

# if name is a file, we extract the lines of the file into an array
if name.split('.')[1]=='txt':
    with open(os.path.join(cwd,name),'r') as file:
        lines = file.readlines()
        names = [line.rstrip() for line in lines]
# otherwise, name is just the name of a single census manifold.
else:
    names = [name]


for mfld in names:

    d = hpc_function.compute_trace_field(mfld,int(prec),int(deg))
    
    end = time()
    
    if d != None:
        p = pickle.dumps(d)
        with open(os.path.join(cwd,'data/{}'.format(mfld)), 'bw') as pfile:
            pfile.write(p)
    
    
    print('name: {}; time: {}'.format(mfld, end-start))


