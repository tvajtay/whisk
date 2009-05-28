#!/usr/bin/env python
"""
This utility spawns a number of sub-processes for asynchronously processing
files located in `datadir` with the aim of making it easier to get the full use
from a multi-core PC.

Example usage:

  batch.py --help
    prints the command line help text

  batch.py /path/to/data/directory
    Uses the defaults to process all the data in the specified directory.

  batch.py /path/to/data/directory -e "./whisk" --args="--no-bar --no-traj" -n 5
    Uses the defaults to process all the data in the specified directory.
    Uses "./whisk" as the executable modified with "--no-bar --no-traj" so the
    call is:
        ./whisk path/to/movie.seq path/to/movie --no-bar --no-traj
    Uses 5 worker processes to complete all the jobs asynchronously.

Compatibility Notes:

  This was written for use with Python 2.5 and requires the `processing` module.
  See http://pypi.python.org/pypi/processing for installation instructions.

  In Python 2.6, the processing module was replaced with a built-in module
  names `multiprocessing`.  To port this script to Python 2.6, replace all 
  mention of the name `processing` with `multiprocessing` in the script below.

Author: Nathan Clack
Date  : 2009-05-18

Copyright (c) 2009 HHMI. Free downloads and distribution are allowed for any
non-profit research and educational purposes as long as proper credit is given
to the author. All other rights reserved.
"""
from processing import freezeSupport as freeze_support
from processing import Pool
import subprocess
from glob import glob
import os,sys

import datetime
import time
from pprint import pprint

import optparse

def run(args):
  print "Got job: "+' '.join(args)
  #return args
  retcode = subprocess.call(args)
  return args,retcode

def doit(path, 
         exe     = "./whisk",
         filter  = "*.seq",
         args    = ["--no-bar"],
         label   = '',
         outdir  = '',
         nproc   = None):                # if nproc is none, will use cpu count
  files = glob(os.path.join(path,filter))
  if not outdir:
    outdir = path
  getfilename = lambda nm: os.path.split( os.path.splitext(nm)[0])[1]
  prefix = lambda nm: os.path.join( outdir, getfilename(nm) )
  if label:
      prefix = lambda nm: os.path.join(outdir, getfilename(nm)+"[%s]"%label)
  jobs = [ [exe,name, prefix(name)] for name in files ]
  for j in jobs:
    j.extend(args)

  assert len(files) > 0, "No %s files found in %s"%(filter,path)

  P = Pool( processes = nproc )
  time.clock()
  result = P.map(run, jobs[:3])
  elapsed = time.clock()

  #
  # REPORT
  #
  maxlen = 0
  for name in files:
    maxlen = max(maxlen, len(name))

  if jobs:
    for args,code in result:
      if code == 0:
        print args[1].rjust(maxlen+1), "[ ] Success"
      else:
        print args[1].rjust(maxlen+1), "[X] FAILED"
    print "Processed %d jobs in a total of %5.3f seconds (%5.3f sec/job)"%(len(jobs),elapsed,elapsed/float(len(jobs)))

if __name__ == '__main__':
  freeze_support()

  #
  # Command line
  #
  usage = "usage: %prog datadir [options]"
  description = \
"""This utility spawns a number of sub-processes for asynchronously processing files
located in `datadir` with the aim of making it easier to get the full use from a
multi-core PC.
"""
  parser = optparse.OptionParser(usage=usage,
                                description=description)
  parser.add_option("-f","--filter",
                    help    = "A filter used to specify which files in the target directory should be used as input. [default: %default]",
                    dest    = "filter",
                    action  = "store",
                    type    = "string",
                    default = "*.seq")
  parser.add_option("-e","--exe",
                    help    = "The executable to run. [default: %default]",
                    dest    = "exe",
                    action  = "store",
                    type    = "string",
                    default = "whisk")
  parser.add_option("-n","--nproc",
                    help    = "Specifies the number of worker processes to use [default: cpu count]",
                    dest    = "nproc",
                    action  = "store",
                    type    = "int",
                    default = None)
  parser.add_option("--args",
                    help    = "The optional arguments to pass to the executable.  Enclose multiple arguments with quotes [default: %default]",
                    dest    = "args",
                    action  = "store",
                    type    = "string",
                    default = "--no-bar")
  parser.add_option("--label",
                    help    = "An optional label to add to output file names. Set to empty quotes for no label. [default: %default]",
                    dest    = "label",
                    action  = "store",
                    type    = "string",
                    default = datetime.datetime.now().strftime("%Y-%m-%d"))
  parser.add_option("-o","--output",
                    help    = "The directory to which output will be saved [default: input directory]",
                    dest    = "outdir",
                    action  = "store",
                    type    = "string",
                    default = None)

  options,args = parser.parse_args()
  options.args = options.args.split()

  if len(args)==0:
    parser.error("Path to movie files required")

  assert( os.path.isdir( args[0] ) )

  doit(args[0], **options.__dict__ )

