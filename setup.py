#!/usr/bin/python
"""Setup TheoryMine"""

import re
import subprocess
import sys
import os


# Sometimes useful for debugging:
#
# print 'USER=%s' % os.environ['USER']
# print 'Args=%d' % len(sys.argv)

GIT_HTTPS_ORIGIN_URL_PREFIX_MATCHER = re.compile(
  r'^https\:\/\/([\w\.]*)\/(.*)$', re.MULTILINE)
GIT_SSH_ORIGIN_URL_PREFIX_MATCHER = re.compile(
  r'^git\@([\w\.]*)\:(.*)$', re.MULTILINE)

#--------------------------------------
# Num  Colour    #define         R G B
#--------------------------------------
# 0    black     COLOR_BLACK     0,0,0
# 1    red       COLOR_RED       1,0,0
# 2    green     COLOR_GREEN     0,1,0
# 3    yellow    COLOR_YELLOW    1,1,0
# 4    blue      COLOR_BLUE      0,0,1
# 5    magenta   COLOR_MAGENTA   1,0,1
# 6    cyan      COLOR_CYAN      0,1,1
# 7    white     COLOR_WHITE     1,1,1

RED=subprocess.check_output(['tput', 'setaf', '1'])
GREEN=subprocess.check_output(['tput', 'setaf', '2'])
YELLOW=subprocess.check_output(['tput', 'setaf', '3'])
BLUE=subprocess.check_output(['tput', 'setaf', '4'])
RESET=subprocess.check_output(['tput', 'sgr0'])

def print_green(s):
  print(GREEN + s + RESET)

def print_yellow(s):
  print(YELLOW + s + RESET)

def print_red(s):
  print(RED + s + RESET)

def try_call(cmd_list):
  print_green(' * %s' % ' '.join(cmd_list))
  status = subprocess.call(cmd_list)
  if status != 0:
    print_red('FAILED.')
    return false;
  return true;

def call_or_die(cmd_list):
  print_green(' * %s' % ' '.join(cmd_list))
  status = subprocess.call(cmd_list)
  if status != 0:
    print_red('FAILED.')
    sys.exit(1)

class GitRepoRef(object):
  def __init__(self, path, domain, method):
    self.path = path
    self.domain = domain
    self.method = method

  def get_git_clone_command(self):
    if self.method == 'https':
      return 'https://' + self.domain + '/' + self.path
    elif self.method == 'ssh':
      return 'git@' + self.domain + ':' + self.path
    else:
      return None

def make_git_repo_ref_from_cur_dir():
  """Gets the prefix string for a git clone command dependening on the current
  directories git setup. i.e. if it is https, then use https. """
  try:
    git_output = subprocess.check_output(['git', 'config', '--get',
      'remote.origin.url'])
  except subprocess.CalledProcessError:
    print_red('FAILED.')
    sys.exit(1)

  https_match = GIT_HTTPS_ORIGIN_URL_PREFIX_MATCHER.match(git_output)
  if https_match:
    return GitRepoRef(path=https_match.group(2), domain=https_match.group(1),
                      method='https')

  ssh_match = GIT_SSH_ORIGIN_URL_PREFIX_MATCHER.match(git_output)
  if ssh_match:
    return GitRepoRef(path=ssh_match.group(2), domain=ssh_match.group(1),
                      method='ssh')

  return None


TMP_DIR='tmp'
DEPS_DIR='external_deps'
SHARED_DIR='docker_shared_dir'

def main(argv):
  gitrepo = make_git_repo_ref_from_cur_dir()

  d = './' + DEPS_DIR
  cmd = ['mkdir', '-p', d]
  if not os.path.isdir(d):
    call_or_die(cmd)
  else:
    print_yellow(' * [skipped: %s]' % ' '.join(cmd))

  d = DEPS_DIR + '/IsaPlanner';
  gitrepo.path = 'TheoryMine/IsaPlanner.git';
  cmd = ['git', 'clone', '--branch=2015.0.2', gitrepo.get_git_clone_command(),
         d]
  if not os.path.isdir(d):
    call_or_die(cmd)
  else:
    print_yellow(' * [skipped: %s]' % ' '.join(cmd))

  d = DEPS_DIR + '/math-robot';
  gitrepo.path = 'TheoryMine/math-robot.git';
  cmd = ['git', 'clone', '--branch=2015.0.2', gitrepo.get_git_clone_command(),
         d]
  if not os.path.isdir(d):
    call_or_die(cmd)
  else:
    print_yellow(' * [skipped: %s]' % ' '.join(cmd))

  d = DEPS_DIR + '/theorymine-website';
  gitrepo.path = 'TheoryMine/theorymine-website.git';
  cmd = ['git', 'clone', '--branch=2015.0.2', gitrepo.get_git_clone_command(),
         d]
  if not os.path.isdir(d):
    call_or_die(cmd)
  else:
    print_yellow(' * [skipped: %s]' % ' '.join(cmd))

  call_or_die(['docker', 'build', '-t', 'theorymine/isaplanner:2015.0.2',
    DEPS_DIR + '/IsaPlanner/'])

  call_or_die(['docker', 'build', '-t', 'theorymine/theorymine:2015.0.2', '.'])

  d = './' + SHARED_DIR
  cmd = ['mkdir', '-p', d]
  if not os.path.isdir(d):
    call_or_die(cmd)
  else:
    print_yellow(' * [skipped: %s]' % ' '.join(cmd))

  print_green('Completed.')

if __name__ == '__main__':
  main(sys.argv)
