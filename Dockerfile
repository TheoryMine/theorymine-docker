# Docker file for TheoryMine

FROM ubuntu:14.04
MAINTAINER Lucas Dixon <lucas.dixon@gmail.com>

# Install additional ubuntu deps for Isabelle/PolyML
ADD docker-setup /docker-setup

# Install the necessary base packages
RUN apt-get update
RUN apt-get install -y openjdk-6-jre git g++ subversion wget make

# Install Isabelle-2009-2
RUN cd /tmp
RUN wget http://isabelle.in.tum.de/website-Isabelle2009-2/dist/Isabelle2009-2_bundle_x86-linux.tar.gz 
RUN tar zxf Isabelle2009-2_bundle_x86-linux.tar.gz -C /usr/local 

# Remove it's pref-configured, but broken for this linux, polyml builds
RUN rm -r /usr/local/Isabelle/contrib/polyml/x86*

# Build polyml 
RUN cd /usr/local/Isabelle/contrib/polyml/src/ 
RUN ./configure 
RUN make 
# Sym-link so that Poly is where Isabelle expects it to be.
RUN ln -s /usr/local/Isabelle/contrib/polyml/src/poly /usr/local/bin/poly

# Have Isabelle re-build all its base logics using the new PolyML
RUN /usr/local/Isabelle/bin/isabelle makeall

# Download and build IsaPlanner/IsaCosy for Isabelle 2009-2
RUN cd /usr/local
RUN svn checkout svn://svn.code.sf.net/p/isaplanner/code/trunk/IsaPlanner/IsaPlanner-2009-2
RUN cd /usr/local/IsaPlanner-2009-2/
RUN /usr/local/Isabelle/bin/isabelle make

# Setup ssh-keys so that we can access the private github repository
# Make sure an ssh-agent is running
RUN eval "$(ssh-agent -s)"
RUN ssh-add /docker-setup/github-keys/theorymine-gmail-github_rsa

# Clone the math robot and build the base-logic for it
RUN cd /usr/local
RUN git clone git@github.com:TheoryMine/math-robot.git
RUN cd /usr/local/math-robot
RUN /usr/local/Isabelle/bin/isabelle make

