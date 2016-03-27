import subprocess
import sys
import os

from . import cprint

def try_call(cmd_list):
  cprint.green(' * %s' % ' '.join(cmd_list))
  status = subprocess.call(cmd_list)
  if status != 0:
    cprint.red('FAILED.')
    return false;
  return true;

def call_or_die(cmd_list):
  cprint.green(' * %s' % ' '.join(cmd_list))
  status = subprocess.call(cmd_list)
  if status != 0:
    cprint.red('FAILED.')
    sys.exit(1)

def try_mkdir(path):
  cmd = ['mkdir', '-p', path]
  if not os.path.isdir(path):
    call_or_die(cmd)
  else:
    cprint.yellow(' * [skipped: %s]' % ' '.join(cmd))
