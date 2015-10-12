#/!bin/bash
set -e

# Get the directory where this script is and set ROOT_DIR to that path. This
# allows script to be run from different directories but always act on the
# directory it is within.
ROOT_DIR="$(cd "$(dirname $0)"; pwd)";
TMP_DIR="$ROOT_DIR/tmp"
SHARED_DIR="$ROOT_DIR/shared_directory"


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

RED=`tput setaf 1`
GREEN=`tput setaf 2`
BLUE=`tput setaf 4`
RESET=`tput sgr0`

function echo_green {
  echo "${GREEN}$1${RESET}"
}

function echo_red {
  echo "${RED}$1${RESET}"
}

function echo_blue {
  echo "${BLUE}$1${RESET}"
}


# A simple bash script to run commands to setup and install all dev dependencies
# (including non-npm ones)
function runAndAssertCmd ()
{
    echo_green "$1"
    echo
    # We use set -e to make sure this will fail if the command returns an error
    # code.
    set -e
    cd $ROOT_DIR && eval $1
}

# Just run the command, ignore errors (e.g. cp fails if a file already exists
# with "set -e")
function runCmd ()
{
    echo_green "$1"
    echo
    cd $ROOT_DIR && eval $1
}

# Setup local directories that will be shared with the docker containers.
runAndAssertCmd "mkdir -p shared_directories"

if [! -a "$SHARED_DIR/math-robot" ] then
 runAndAssertCmd "git clone git@github.com:TheoryMine/math-robot.git \
   shared_directories/math-robot"
fi
if [! -a "$SHARED_DIR/theorymine-website" ] then
 runAndAssertCmd "git clone git@github.com:TheoryMine/theorymine-website.git \
   shared_directories/theorymine-website"
fi

runAndAssertCmd "docker build -t theorymine/isaplanner:2009.2 \
  ./isaplanner_docker/"

# The tmp directory is for
runAndAssertCmd "mkdir -p tmp"
