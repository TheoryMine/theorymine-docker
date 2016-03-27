import subprocess
import sys
import os
import re

from . import command
from . import cprint

GIT_HTTPS_ORIGIN_URL_PREFIX_MATCHER = re.compile(
  r'^https\:\/\/([\w\.]*)\/(.*)$', re.MULTILINE)
GIT_SSH_ORIGIN_URL_PREFIX_MATCHER = re.compile(
  r'^git\@([\w\.]*)\:(.*)$', re.MULTILINE)

class RepoRef(object):
  def __init__(self, path, domain, method):
    self.path = path
    self.domain = domain
    self.method = method

  def get_clone_command(self):
    if self.method == 'https':
      return 'https://' + self.domain + '/' + self.path
    elif self.method == 'ssh':
      return 'git@' + self.domain + ':' + self.path
    else:
      return None

def make_repo_ref_from_cur_dir():
  """Gets the prefix string for a git clone command dependening on the current
  directories git setup. i.e. if it is https, then use https. """
  try:
    git_output = subprocess.check_output(['git', 'config', '--get',
      'remote.origin.url'])
  except subprocess.CalledProcessError:
    cprint.red('FAILED: make_repo_ref_from_cur_dir. This command must be run '
      'from a directory that is a github directory')
    sys.exit(1)

  https_match = GIT_HTTPS_ORIGIN_URL_PREFIX_MATCHER.match(git_output)
  if https_match:
    return RepoRef(path=https_match.group(2), domain=https_match.group(1),
                   method='https')

  ssh_match = GIT_SSH_ORIGIN_URL_PREFIX_MATCHER.match(git_output)
  if ssh_match:
    return RepoRef(path=ssh_match.group(2), domain=ssh_match.group(1),
                   method='ssh')

  return None

def try_clone(git_repo, branch, as_local_dir):
  cmd = ['git', 'clone', '--branch=' + branch, git_repo.get_clone_command(),
         as_local_dir]
  if not os.path.isdir(as_local_dir):
    command.call_or_die(cmd)
  else:
    cprint.yellow(' * [skipped: %s]' % ' '.join(cmd))

def make_local_clones(repos):
  gitrepo = make_repo_ref_from_cur_dir()
  for r in repos:
    gitrepo.path = r['git_repo'];
    try_clone(git_repo=gitrepo, branch=r['branch'],
              as_local_dir=r['as_local_dir'])
