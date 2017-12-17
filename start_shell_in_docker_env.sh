# start an interactive bash shell in the docker environment.
docker run \
  -v $(pwd)/docker_shared_dir/:/theorymine/docker_shared_dir \
  -w /theorymine/ \
  -ti \
  theorymine/theorymine \
  /bin/bash
