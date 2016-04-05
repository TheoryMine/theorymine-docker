# start an interactive bash shell in the docker environment.
docker run \
  -v $(pwd)/docker_shared_dir/:/theorymine/theorymine-website/generated_certificates \
  -w /theorymine/theorymine-website/ \
  -ti \
  theorymine/theorymine \
  /bin/bash
