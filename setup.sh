#/!bin/bash
set -e

# Local setup for docker.
mkdir -p shared_directories
git clone git@github.com:TheoryMine/math-robot.git \
  shared_directories/math-robot
git clone git@github.com:TheoryMine/theorymine-website.git \
  shared_directories/theorymine-website
