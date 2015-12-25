# Docker file for TheoryMine

FROM theorymine/isaplanner:2015.0.2
MAINTAINER Lucas Dixon <lucas.dixon@gmail.com>

# Install additional php tools
RUN apt-get install -y \
  php5 \
  php5-mcrypt

# NOTE: if you already have a docker image, but want to update it to get
# the latest local files, you can update the ID which will invalidate cache at
# this point.
RUN echo "id:1"

# Copy external dependencies into docker filespace.
COPY external_deps/math-robot /theorymine/math-robot
COPY external_deps/theorymine-website /theorymine/theorymine-website

# Create the Isabelle image for the math-robot.
RUN cd /theorymine/math-robot/ && \
  /usr/local/Isabelle2015/bin/isabelle build \
    -d /usr/local/Isabelle2015/contrib/IsaPlanner \
    -d . \
    -b HOL-TheoryMine
