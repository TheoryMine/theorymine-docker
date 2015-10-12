theorymine-docker
=================

This repo contains the tools and Docker image to setup TheoryMine. You first need to have [docker](https://www.docker.com/) installed (and/or with boot2docker).
Note, if you install on linux without boot2docker, then all your docker commands need to be run as superuser (i.e. prefixed with the sudu command). If you have docker and boot2docker, then this command starts up boot2docker which, after entering the command lines it tells you to set some environment variables, will allow you to run the docker command.

```
# Startup boot2docker to enable docker commands
boot2docker up

# Get a checkout of theorymine-docker.
git clone git@github.com:TheoryMine/theorymine-docker.git
cd theorymine-docker

# Build the docker file; this will take a while (has to download ubuntu,
# and then install everything, and then build all the
# Isabelle/IsaPlanner/IsaCosy images).
docker build -t theorymine/theorymine-image .
```

To enter the docker environment and get a bash shell there, you can then run:
```
sudo docker run -t -i theorymine:theorymine-image /bin/bash
```

To enter a docker environment with IsaPlanner setup and get a bash shell there, you can then run:
```
sudo docker run -t -i theorymine:theorymine-image /bin/bash
```
