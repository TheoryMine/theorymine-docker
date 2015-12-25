# theorymine-docker

This repo contains the tools and Docker image to setup TheoryMine. It assumes you have [docker](https://www.docker.com/) installed and setup.

## Install and setup of theorymine-docker

```
# Get a checkout of theorymine-docker.
git clone git@github.com:TheoryMine/theorymine-docker.git
cd theorymine-docker

# Build the docker image for IsaPlanner
sh ./setup.sh
```

To enter a docker environment with IsaPlanner setup and get a bash shell there, you can then run:

```
docker run -v $(pwd)/docker_shared_dir/:/theorymine/docker_shared_dir \
  -i -t theorymine/theorymine:2015.0.2 \
  /bin/bash
```

From that shell you can then run theorem synthesis.


## To mine theorems

From within the Docker environment:

```
cd /theorymine/math-robot/
pico run_synth.thy
## Now edit the params at the bottom of the file, save and quit.
/usr/local/Isabelle2015/bin/isabelle build \
  -d /usr/local/Isabelle2015/contrib/IsaPlanner \
  -d . -b RunSynth
```

In a separate bash invironment, you can then do this to see the logs:
```
docker ps
```

Then look at the docker container name and set it to an env variable e.g.

```
export THEORYMINE_CONTAINER=kickass_snyder

docker exec -t -i /bin/bash
```

Now, from that docker container shell, you can look at the generated theorems:

```
ls /theorymine/math-robot/output
```

or look at the logs when things go wrong:
```
tail -n 1000 \
  -f /root/.isabelle/Isabelle2015/heaps/polyml-5.5.2_x86_64-linux/log/RunSynth
```

## To upload theorems

```
php upload_theorems.php output DOMAIN PASSWORD
```


## To generate certificates

```
docker run \
  -v $(pwd)/docker_shared_dir/:/theorymine/docker_shared_dir \
  -v $HOME/tmp/outside-of-docker-theorymine:/tmp/inside-of-docker-theorymine \
  -i -t theorymine/isaplanner:2015.0.2 \
  /bin/bash
```
