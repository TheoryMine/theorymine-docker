# theorymine-docker

This repo contains the tools and Docker image to setup TheoryMine. It assumes you have [docker](https://www.docker.com/) installed and setup.

## Install and setup of theorymine-docker

```bash
# Get a checkout of theorymine-docker.
git clone git@github.com:TheoryMine/theorymine-docker.git
cd theorymine-docker

# Build the docker image for IsaPlanner
python ./setup.py
```

The key thing this does is build the needed docker images:

```
docker build -t theorymine/isaplanner external_deps/IsaPlanner/
docker build -t theorymine/theorymine-docker .
```

Once the setup scrip tis done, you can enter a docker environment with
IsaPlanner setup and get a bash shell there:

```bash
docker run -v $(pwd)/docker_shared_dir/:/theorymine/docker_shared_dir \
  -i -t theorymine/theorymine \
  /bin/bash
```

Note the `-v` command shares the local `docker_shared_dir` directory between
your external docker environment with the directory
`/theorymine/docker_shared_dir` inside the docker environment.

From that shell you can then run theorem synthesis,
or certificate generation/processing.

## To mine theorems

From within the Docker environment:

```bash
cd /theorymine/math-robot/
pico run_synth.thy
## Now edit the params at the bottom of the file, save and quit.
/usr/local/Isabelle2015/bin/isabelle build \
  -d /usr/local/Isabelle2015/contrib/IsaPlanner \
  -d . -b RunSynth
```

In a separate bash invironment, you can then do this to see the logs:

```bash
docker ps
```

Then look at the docker container name and set it to an env variable e.g.

```bash
export THEORYMINE_CONTAINER=kickass_snyder
docker exec -t -i $THEORYMINE_CONTAINER /bin/bash
```

Now, from that docker container shell, you can look at the generated theorems:

```bash
ls /theorymine/math-robot/output
```

or look at the logs when things go wrong:

```bash
tail -n 1000 \
  -f /root/.isabelle/Isabelle2015/heaps/polyml-5.5.2_x86_64-linux/log/RunSynth
```

## To upload theorems

```bash
php upload_theorems.php output DOMAIN PASSWORD
```

## To generate certificates

To download the `latex_bits.json` file from the web, and the use it to
generate local latex files and build them to create the PDFs and JPG
images for certificates run the following:

```bash
export THEORYMINE_CERT_ID=8046b28b5216e4ac9daed8ffcc685199c4d6
node build/tools/latexify.js \
  --inputCid=$THEORYMINE_CERT_ID \
  --outputDir=docker_shared_dir/$THEORYMINE_CERT_ID
```

This will put the generated certificate files into a directory
`docker_shared_dir/$THEORYMINE_CERT_ID`

You can re-create the latex files
(without downloading an update `latex_bits.json` file) using:

```
node build/tools/latexify.js \
  --inputFile=docker_shared_dir/$THEORYMINE_CERT_ID/latex_bits.json \
  --outputDir=docker_shared_dir/$THEORYMINE_CERT_ID
```

If you hack the latex locally, and just want to rerun the `pdflatex` and
`convert` commands to regenerate the pdfs and jpgs, run:

```
node build/tools/latexify.js \
  --outputDir=docker_shared_dir/$THEORYMINE_CERT_ID
```

#### To generate certificates from within a docker container

From this directory, run:

```bash
docker run \
  -v $(pwd)/docker_shared_dir/:/theorymine/theorymine-website/generated_certificates \
  -w /theorymine/theorymine-website/ \
  -i -t theorymine/theorymine \
  /bin/bash
```

Then in the started docker shell (in the same command line with the new docker
prompt), you can run:

```bash
cd /theorymine/theorymine-website/
# Set the certificate id here...
export THEORYMINE_CERT_ID=80103f9220724a9a9b765619d77237aef8d8
# TODO(ldixon): write this bit.
```

This will put generated certificate files to be uploaded into the docker-
environments directory `/theorymine/generated_certificates/$THEORYMINE_CERT_ID`
which is mapped to the local directory `docker_shared_dir/`, which you can then
upload using the website's admin interface.

## To upload certificates

Once certificate files have been generated for a theorem (they are in the `docker_shared_dir` directory), you can upload them to the website with:

```bash
./upload_certificate_files.py $THEORYMINE_CERT_ID
```

## Local setup (For debugging, and working outside of Docker)

Install latex, node (and npm, using [nvm](https://github.com/creationix/nvm#installation)), php, python, pip.

Install the relevant global npm packages:

```
npm install -g yarn typescript mocha
```

Install local node package dependencies (specified in the package.json file):

```
yarn install
```

Build the typescript/node code locally (used for top-level scripting):

```
yarn run build
```
