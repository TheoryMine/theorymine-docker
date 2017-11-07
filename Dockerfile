# Docker file for TheoryMine

FROM theorymine/isaplanner
MAINTAINER Lucas Dixon <lucas.dixon@gmail.com>

# Install additional php tools
RUN apt-get update && apt-get install -y \
  php5 php5-mcrypt \
  python-pip \
  nodejs npm

RUN pip install --upgrade pip && pip install --upgrade virtualenv

RUN npm install -g yarn typescript mocha

# NOTE: if you already have a docker image, but want to update it to get
# the latest local files, you can update the ID which will invalidate cache at
# this point.
RUN echo "id:1"

# Copy MathRobot into the docker filespace.
COPY external_deps/math-robot /theorymine/math-robot

# Create the Isabelle image for the math-robot.
RUN cd /theorymine/math-robot/ && \
  /usr/local/Isabelle2015/bin/isabelle build \
    -d /usr/local/Isabelle2015/contrib/IsaPlanner \
    -d . \
    -b HOL-TheoryMine

# Copy the website files into the docker filespace.
COPY external_deps/theorymine-website /theorymine/theorymine-website

RUN yarn install