/*
Script to upload a JSON theory file.

Example usage:

node ./build/tools/theorem_uploader.js \
  --theoryJsonFile=tmp/T_13__f_190.json

*/

import * as path from 'path';
import * as config from './config';
import * as promised_request from './promised_request';
import * as theorymine_latex from './theorymine_latex';
import * as fs from 'fs-extra';
import * as yargs from 'yargs';
import * as escape_regexp from 'escape-string-regexp';
import * as child_process from 'child_process';

// Command line arguments.
interface Args {
  configPath : string,
  // Input JSON for theorems to upload.
  theoryJsonFile ?: string,
  theoryJsonDir ?: string,
};

async function uploadTheory(conf : config.Config, theoryJsonFile : string) {
  let theoryFileContents = fs.readFileSync(theoryJsonFile, 'utf-8');
  let theoryObj = JSON.parse(theoryFileContents);
  theoryObj['pass'] = 'vtppassU1';
  theoryObj['kind'] = 'unnamed';

  let result = await promised_request.post(
    conf.server + '/?go=import_json_theorems',
    { json: theoryObj });

  console.log(`result.body: ${typeof(result.body)}`);
  console.log(JSON.stringify(result.body, null, 2));

  fs.writeFileSync(
    theoryJsonFile.replace(/.json$/, '.upload_result.json'),
    JSON.stringify(result.body, null, 2),
    { encoding: 'utf-8' });
}

async function main(args : Args) {
  let conf : config.Config = JSON.parse(fs.readFileSync(args.configPath, 'utf8'));

  if(!args.theoryJsonFile && !args.theoryJsonDir) {
    throw new Error('At least one of --theoryJsonFile or --theoryJsonDir must be provided.');
  }

  if (args.theoryJsonFile !== undefined) {
    await uploadTheory(conf, args.theoryJsonFile);
  } else if (args.theoryJsonDir !== undefined) {
    let isResultRegExp = new RegExp(/\.upload_result\.json$/);
    let isJsonFileRegExp = new RegExp(/\.json$/);
    let files : string[] = [];
    fs.readdirSync(args.theoryJsonDir).forEach(file => files.push(file));
    for(let file of files) {
      if (file.match(isJsonFileRegExp) && !file.match(isResultRegExp)) {
        console.log(path.join(args.theoryJsonDir, file));
        await uploadTheory(conf, path.join(args.theoryJsonDir, file));
      }
    }
  }
    // JSON.stringify(JSON.parse(result.body), null, 2));
}

let args = yargs
    .option('configPath', {
        describe: 'Path to JSON file of questions to upload'
    })
    .option('theoryJsonFile', {
      describe: 'Use theory JSON in this text file'
    })
    .option('theoryJsonDir', {
      describe: 'Use all JSON files in this directory'
    })
    .default('configPath', 'build/config/config.json')
    .demandOption(['configPath'],
      'Please provide --configPath (or use defaul).')
    .help()
    .argv;

main(args as any as Args)
  .then(() => {
    console.log('Success!');
  }).catch(e => {
    console.error('Failed: ', e.message);
  });