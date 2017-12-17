# Docker file for TheoryMine

FROM theorymine/isaplanner
MAINTAINER Lucas Dixon <lucas.dixon@gmail.com>

# node/npm v6.
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
# Yarn setup
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# Install additional php tools
RUN apt-get update && apt-get install -y \
  php5 php5-mcrypt \
  python-pip \
  build-essential \
  nodejs \
  curl \
  yarn

RUN pip install --upgrade pip && pip install --upgrade virtualenv

RUN mkdir -p /theorymine/
ADD . /theorymine/
WORKDIR /theorymine/

RUN npm install typescript mocha
RUN yarn install
RUN yarn run build

# NOTE: if you already have a docker image, but want to update it to get
# the latest local files, you can update the ID which will invalidate cache at
# this point.
RUN echo "id:1"

# Create the Isabelle image for the math-robot.
RUN cd /theorymine/external_deps/math-robot/ && \
  /usr/local/Isabelle2015/bin/isabelle build \
    -d /usr/local/Isabelle2015/contrib/IsaPlanner \
    -d . \
    -b HOL-TheoryMine