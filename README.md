theorymine-docker
=================

This repo contains the tools and Docker image to setup TheoryMine. You first need to have [docker](https://www.docker.com/) installed.

```
# Get a checkout of theorymine-docker.
git clone git@github.com:TheoryMine/theorymine-docker.git
cd theorymine-docker

# Build the docker image for IsaPlanner
sh ./setup.sh

## in the future: docker build -t theorymine/theorymine-image .
```

To enter a docker environment with IsaPlanner setup and get a bash shell there, you can then run:
```
docker run -v $(pwd)/shared_directories/:/theorymine -t -i theorymine/isaplanner:2009.2 /bin/bash
```

From that shell you can then do this:
```
cd /theorymine/math-robot/isabelle-code-2009-2
pico run_synth.thy
## Now edit the params at the bottom of the file, save and quit.
/usr/local/Isabelle/bin/isabelle make
```

In a separate bash invironment, you can then do this to see the logs:
```
docker ps
# Then look at the docker container name and set it to an env variable e.g.

export THEORYMINE_CONTAINER=kickass_snyder

docker exec -t -i $THEORYMINE_CONTAINER /bin/bash
```

Now, from that docker container shell, you can do things like this:

```
# Look at the the output directory to see what functions generated theorems:
cd /theorymine/math-robot/isabelle-code-2009-2
ls output

# Look at the logs:
tail -n 1000 -f /root/.isabelle/heaps/Isabelle2009-2/polyml-5.3.0_x86-linux/log/tm_initial_
```

To upload theorems:
```
php upload_theorems.php output DOMAIN PASSWORD
```

To generate certificates:
```
docker run \
  -v $(pwd)/shared_directories/:/theorymine \
  -v $HOME/tmp/outside-of-docker-theorymine:/tmp/inside-of-docker-theorymine \
  -t -i theorymine/isaplanner:2009.2 \
  /bin/bash
```
