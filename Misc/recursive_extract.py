#!/usr/bin/env python2

import tarfile
import zipfile
import gzip
import bz2
import sys
import StringIO
import subprocess
import os
from backports import lzma

def identify_archive(stream):
    p = subprocess.Popen(['file', '-bi', '-'], stdout=subprocess.PIPE,stdin=subprocess.PIPE)
    output, output_err = p.communicate(stream)
    return output[0:output.find(';')]
    
def punzip(stream, depth):
    type = identify_archive(stream)
    
    depth += 1
    
    if depth == 30000:
        print "reached max depth"
        with open('flag.punzip', 'w') as outfile:
            outfile.write(stream)
        return
    elif type == 'application/x-tar':
        t = tarfile.open(mode="r", fileobj=StringIO.StringIO(stream))
        for entry in t:
            return punzip(t.extractfile(entry).read(), depth)
    elif type == 'application/zip':
        z = zipfile.ZipFile(StringIO.StringIO(stream))
        return punzip(z.read(z.namelist()[0]), depth)
    elif type == 'application/gzip':
        g = gzip.GzipFile(fileobj=StringIO.StringIO(stream))
        return punzip(g.read(), depth)
    elif type == 'application/x-bzip2':
        b = bz2.decompress(stream)
        return punzip(b, depth)
    elif type == 'application/x-xz':
        a = lzma.decompress(stream)
        return punzip(a, depth)
    else:
        print "done"
        with open('flag.found', 'w') as flagfile:
            flagfile.write(stream)
        return

if __name__ == '__main__':
    if os.path.exists('flag.punzip'):
        with open('flag.punzip') as file:
            punzip(file.read(), 0)
    else:
        with open(sys.argv[1]) as file:
            punzip(file.read(), 0)
