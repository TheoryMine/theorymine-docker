# Docker file for TheoryMine

FROM theorymine/isaplanner
MAINTAINER Lucas Dixon <lucas.dixon@gmail.com>

RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -

# Install additional php tools
RUN apt-get update && apt-get install -y \
  php5 php5-mcrypt \
  python-pip \
  build-essential \
  nodejs \
  curl

RUN pip install --upgrade pip && pip install --upgrade virtualenv

RUN mkdir -p /theorymine-docker/
ADD . /theorymine-docker/
WORKDIR /theorymine-docker/

RUN npm install -g yarn typescript mocha
RUN yarn install
RUN yarn run build

# NOTE: if you already have a docker image, but want to update it to get
# the latest local files, you can update the ID which will invalidate cache at
# this point.
RUN echo "id:1"

# Create the Isabelle image for the math-robot.
RUN cd /theorymine-docker/external_deps/math-robot/ && \
  /usr/local/Isabelle2015/bin/isabelle build \
    -d /usr/local/Isabelle2015/contrib/IsaPlanner \
    -d . \
    -b HOL-TheoryMine