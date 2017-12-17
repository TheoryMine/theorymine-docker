# Creates a certificate using the docker environment.
export THEORYMINE_CERT_ID=$1

docker run \
  -v $(pwd)/docker_shared_dir/:/theorymine/docker_shared_dir \
  theorymine/theorymine \
  /bin/bash -c "node build/tools/latexify.js \
    --inputCid=$THEORYMINE_CERT_ID \
    --outputDir=docker_shared_dir/$THEORYMINE_CERT_ID"