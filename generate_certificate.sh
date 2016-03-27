# Creates a certificate using the docker environment.
docker run \
  -v $(pwd)/docker_shared_dir/:/theorymine/theorymine-website/generated_certificates \
  -w /theorymine/theorymine-website/ \
  theorymine/theorymine \
  /bin/bash -c "/theorymine/theorymine-website/run_certificate_generation.sh $1"
