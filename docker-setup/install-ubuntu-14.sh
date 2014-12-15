#!/bin/env bash

# Assumes a linux environment: Ubutnu 14

# Install the necessary base packages
apt-get update
apt-get install -y openjdk-6-jre git g++ subversion wget make

# Install Isabelle-2009-2
cd /tmp
wget http://isabelle.in.tum.de/website-Isabelle2009-2/dist/Isabelle2009-2_bundle_x86-linux.tar.gz 
tar zxf Isabelle2009-2_bundle_x86-linux.tar.gz -C /usr/local 

# Remove it's pref-configured, but broken for this linux, polyml builds
rm -r /usr/local/Isabelle/contrib/polyml/x86*

# Build polyml 
cd /usr/local/Isabelle/contrib/polyml/src/ 
./configure 
make 
# Sym-link so that Poly is where Isabelle expects it to be.
ln -s /usr/local/Isabelle/contrib/polyml/src/poly /usr/local/bin/poly

# Have Isabelle re-build all its base logics using the new PolyML
/usr/local/Isabelle/bin/isabelle makeall

# Download and build IsaPlanner/IsaCosy for Isabelle 2009-2
cd /usr/local
svn checkout svn://svn.code.sf.net/p/isaplanner/code/trunk/IsaPlanner/IsaPlanner-2009-2
cd /usr/local/IsaPlanner-2009-2/
/usr/local/Isabelle/bin/isabelle make

# Setup ssh-keys so that we can access the private github repository
# Make sure an ssh-agent is running
eval "$(ssh-agent -s)"
ssh-add github-keys/theorymine-gmail-github_rsa

# Clone the math robot and build the base-logic for it
cd /usr/local
git clone git@github.com:TheoryMine/math-robot.git
cd /usr/local/math-robot
/usr/local/Isabelle/bin/isabelle make
