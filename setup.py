#!/usr/bin/python
"""Setup TheoryMine

Running this python script does the following:

1. clones the needed repositories for running TheoryMine (they are placed in
the `external_deps` subdirectory). This uses whatever git access method (https
or ssh) is used for the repository that in this directory.

2. Creates a local directory to be shared with docker (`docker_shared_dir`).

3. Builds the docker image for theorymine.
"""

import re
import sys

from lib import cprint
from lib import command
from lib import git

# Sometimes useful for debugging:
#
# print 'USER=%s' % os.environ['USER']
# print 'Args=%d' % len(sys.argv)

TMP_DIR='tmp'
DEPS_DIR='external_deps'
SHARED_DIR='docker_shared_dir'

DEP_GITHUB_REPOS=[
  {'git_repo':'TheoryMine/IsaPlanner.git',
   'branch':'master',
   'as_local_dir':DEPS_DIR + '/IsaPlanner',
  },
  {'git_repo':'TheoryMine/math-robot.git',
   'branch':'master',
   'as_local_dir':DEPS_DIR + '/math-robot',
  },
  {'git_repo':'TheoryMine/theorymine-website.git',
   'branch':'master',
   'as_local_dir':DEPS_DIR + '/theorymine-website',
  },
]

def main(argv):
  command.try_mkdir('./' + DEPS_DIR)
  git.make_local_clones(DEP_GITHUB_REPOS)
  command.call_or_die(['docker', 'build', '-t',
    'theorymine/isaplanner', DEPS_DIR + '/IsaPlanner/'])
  command.call_or_die(['docker', 'build', '-t',
    'theorymine/theorymine', '.'])
  command.try_mkdir('./' + SHARED_DIR)
  cprint.green('Completed.')

if __name__ == '__main__':
  main(sys.argv)
