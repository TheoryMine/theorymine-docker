# Docker file for TheoryMine

FROM isaplanner:2009.2
MAINTAINER Lucas Dixon <lucas.dixon@gmail.com>

# Install additional ubuntu deps for Isabelle/PolyML
COPY docker_setup /docker_setup

# NOTE: if you already have a docker image, and just want to update it to get
# the theorymine latest clone of repo's from github, update the ID on this echo
# line e.g. `echo "id:2"` to avoid docker's cache.
RUN echo "id:1"

# Note: We use ssh-keys so that we can access the private github repository via
# the github delpoy keys flow. This involves making sure an ssh-agent is
# running and then clone repository, then killing the agent.

# Install the math-robot.
RUN eval "$(ssh-agent -s)" && \
  chmod 600 /docker_setup/github-keys/theorymine-gmail-mathbot-github_rsa && \
  ssh-add /docker_setup/github-keys/theorymine-gmail-mathbot-github_rsa && \
  echo `ssh -T -o StrictHostKeyChecking=no -o VerifyHostKeyDNS=yes git@github.com` && \
  cd /usr/local && \
  git clone git@github.com:TheoryMine/math-robot.git && \
  ssh-agent -k && \
  cd /usr/local/math-robot/isabelle-code-2009-2 && \
  /usr/local/Isabelle/bin/isabelle make

# Install the website code (includes code for certificate generation using
# latex etc).
RUN eval "$(ssh-agent -s)" && \
  chmod 600 /docker_setup/github-keys/theorymine-gmail-website-github_rsa && \
  ssh-add /docker_setup/github-keys/theorymine-gmail-website-github_rsa && \
  cd /usr/local && \
  git clone git@github.com:TheoryMine/theorymine-website.git && \
  ssh-agent -k
