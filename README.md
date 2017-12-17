# theorymine-docker

This repo contains the tools and Docker image to setup TheoryMine. It assumes you have [docker](https://www.docker.com/) installed and setup.

## Install and setup of theorymine-docker

1. Get a checkout of theorymine-docker.

  ```bash
  git clone git@github.com:TheoryMine/theorymine-docker.git
  cd theorymine-docker
  ```

2. Create a `config.json` file in the build directory, like so:

  ```
  echo \
    '{ "server": "http://theorymine.com" }' \
    > build/config.json
  ```

  In future, we'll be moving any passwords here, so that they don't live in the repository.

3. Now you can setup the python environment and build the docker image:

  ```
  python ./setup.py
  ```

  The key thing this does is build the needed docker images:

  ```
  docker build -t theorymine/isaplanner external_deps/IsaPlanner/
  docker build -t theorymine/theorymine .
  ```

## Do stuff in the docker environment

Once the setup script is done, you can enter a docker environment with
IsaPlanner and TheoryMine already setup, and get a bash shell by running
`start_shell_in_docker_env.sh` which executes:

```bash
docker run \
  -v $(pwd)/docker_shared_dir/:/theorymine/docker_shared_dir \
  -ti \
  theorymine/theorymine \
  /bin/bash
```

Note the `-v` command shares the local `docker_shared_dir` directory between
your external docker environment with the directory
`/theorymine/docker_shared_dir` inside the docker environment.

From that shell you can then run theorem synthesis,
or certificate generation/processing.

## Mine theorems

From within the Docker environment:

```bash
cd /theorymine/external_deps/math-robot/
pico run_synth.thy
## Now edit the params at the bottom of the file, save and quit.
/usr/local/Isabelle2015/bin/isabelle build \
  -d /usr/local/Isabelle2015/contrib/IsaPlanner \
  -d . -b RunSynth
```

In a separate bash environment, you can then do this to see the running docker environments:

```bash
docker ps
```

Take a note of the name, and set it to an env variable e.g.

```bash
export THEORYMINE_CONTAINER=<name>
docker exec -t -i $THEORYMINE_CONTAINER /bin/bash
```

Now you have another shell in the same docker environment, and from that
docker container shell you can look at the generated theorems:

```bash
ls /theorymine/external_deps/math-robot/output
```

You can also look at the logs when things go wrong:

```bash
tail -n 1000 \
  -f /root/.isabelle/Isabelle2015/heaps/polyml-5.5.2_x86_64-linux/log/RunSynth
```

## Upload theorems

```bash
php upload_theorems.php output DOMAIN PASSWORD
```

## Generate certificates

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

To generate certificates from within a docker container, its the same as outside. You
just first start with a shell in the docker environment.

It will put generated certificate files to be uploaded into the docker-
environments directory `/theorymine/docker_shared_dir/$THEORYMINE_CERT_ID`
which is mapped to the local directory `docker_shared_dir/` in the external environment,
which you can then upload using the website's admin interface, or the upload script below
(which can also be run from either inside or outside docker).

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

Makes sure there is a template `config.json` file in `build/`

```
yarn run setup
```

Build the typescript/node code locally (used for top-level scripting):

```
yarn run build
```

Built files end up in the `build/tools` directory.