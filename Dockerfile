# Docker file for TheoryMine

FROM ubuntu:14.04
MAINTAINER Lucas Dixon <lucas.dixon@gmail.com>

# Install additional ubuntu deps for Isabelle/PolyML
COPY docker-setup /docker-setup

# Install the necessary base packages for Isabelle/TheoryMine theorem
# generation
RUN apt-get update && apt-get install -y \
  g++ \
  git \
  make \
  openjdk-6-jre \
  subversion \
  wget

# Install additional packages for latex/certifictae/image generation
RUN apt-get install -y \
  imagemagick \
  curl \
  texlive-latex-extra

# Install Isabelle-2009-2
RUN cd /tmp && wget http://isabelle.in.tum.de/website-Isabelle2009-2/dist/Isabelle2009-2_bundle_x86-linux.tar.gz && tar zxf Isabelle2009-2_bundle_x86-linux.tar.gz -C /usr/local

# Remove it's pre-configured polyml builds which are broken for this linux
RUN rm -r /usr/local/Isabelle/contrib/polyml/x86*

# Build polyml
RUN cd /usr/local/Isabelle/contrib/polyml/src/ && ./configure && make
# Sym-link so that Poly is where Isabelle expects it to be.
RUN ln -s /usr/local/Isabelle/contrib/polyml/src/poly /usr/local/bin/poly

# Have Isabelle re-build all its base logics using the new PolyML
RUN /usr/local/Isabelle/bin/isabelle makeall

# Download and build IsaPlanner/IsaCosy for Isabelle2009-2
RUN cd /usr/local && \
  svn checkout svn://svn.code.sf.net/p/isaplanner/code/trunk/IsaPlanner/IsaPlanner-2009-2 && \
  cd /usr/local/IsaPlanner-2009-2/ && \
  /usr/local/Isabelle/bin/isabelle make

# Setup ssh-keys so that we can access the private github repository
# Make sure an ssh-agent is running and then clone the math robot and build
# the base-logic for it
RUN eval "$(ssh-agent -s)" && \
  chmod 600 /docker-setup/github-keys/theorymine-gmail-mathbot-github_rsa && \
  ssh-add /docker-setup/github-keys/theorymine-gmail-mathbot-github_rsa && \
  chmod 600 /docker-setup/github-keys/theorymine-gmail-website-github_rsa && \
  ssh-add /docker-setup/github-keys/theorymine-gmail-website-github_rsa && \
  echo `ssh -T -o StrictHostKeyChecking=no -o VerifyHostKeyDNS=yes git@github.com`

# NOTE: if you already have a docker image, and just want to update it to get
# the theorymine latest clone of repo's from github, update the ID on this echo
# line e.g. `echo "id:2"` to avoid docker's cache.
RUN echo "id:1"

# Install the math-robot.
RUN cd /usr/local && \
  git clone git@github.com:TheoryMine/math-robot.git && \
  cd /usr/local/math-robot/isabelle-code-2009-2 && \
  /usr/local/Isabelle/bin/isabelle make

# Install the website code (includes code for certificate generation using
# latex etc).
RUN cd /usr/local && \
  git clone git@github.com:TheoryMine/theorymine-website.git
