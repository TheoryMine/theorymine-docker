import * as path from 'path';
import * as config from './config';
import * as promised_request from './promised_request';
import * as theorymine_latex from './theorymine_latex';
import * as fs from 'fs-extra';
import * as yargs from 'yargs';
import * as escape_regexp from 'escape-string-regexp';
import * as child_process from 'child_process';

/*
node build/tools/latexify.js \
  --inputFile=src/testdata/example_cert_latex_bits.json \
  --outputDir=tmp

node build/tools/latexify.js \
  --inputCid=16327f93873b5723b3939d4b54223b226f39f \
  --outputDir=tmp

export THEORYMINE_CERT_ID=16327f93873b5723b3939d4b54223b226f39f
node build/tools/latexify.js \
  --inputCid=$THEORYMINE_CERT_ID \
  --outputDir=docker_shared_dir/$THEORYMINE_CERT_ID
*/

// Command line arguments.
interface Args {
  configPath : string,
  // Certificate ID.
  inputCid ?: string,
  inputFile ?: string,
  outputDir : string,
};

interface LatexJsonBits {
  date: string;
  thm_title: string;
  thm_body: string;
  proof_body: string;
  thy_title: string;
  thy_body: string;
};

async function main(args : Args) {
  let conf : config.Config = JSON.parse(fs.readFileSync(args.configPath, 'utf8'));

  let latexJsonBits : LatexJsonBits;
  if (args.inputCid && args.inputFile) {
    throw Error('Exactly one of --inputCid or --inputFile must be provided, not both.');
  } else if (args.inputCid) {
    let result = await promised_request.post(
      conf.server + '/?go=latex_bits_json',
      { form: { pass: conf.pass, cid: args.inputCid } });
    latexJsonBits = JSON.parse(result.body);
  } else if (args.inputFile) {
    latexJsonBits = JSON.parse(fs.readFileSync(args.inputFile, { encoding: 'utf-8' }));
  } else {
    throw Error('Exactly one of --inputCid or --inputFile must be provided.');
  }

  console.log(JSON.stringify(latexJsonBits, null, 2));

  let thyParts = theorymine_latex.thyToLatex(
    theorymine_latex.textToLatex(latexJsonBits.thy_body));

  const certificateLatexData = {
    thm_title: theorymine_latex.textToLatex(latexJsonBits.thm_title),
    thm_body: theorymine_latex.formulaToLatex(
      theorymine_latex.textToLatex(latexJsonBits.thm_body)),
    datatypeDef: thyParts.datatypeDef,
    functionType: thyParts.functionType,
    functionDef: thyParts.functionDef,
    date: latexJsonBits.date,
    proof: 'Proof outline: by induction and rippling',
  }
  console.log('certificateLatexData, Latex-ready:');
  console.log(JSON.stringify(certificateLatexData, null, 2));

  const replacements : {[match:string]:string} = {}
  replacements['*********THEOREM_NAME*********'] = certificateLatexData.thm_title
  replacements['*********THEOREM*********'] = certificateLatexData.thm_body;
  replacements['*********DATATYPE_DEF*********'] = certificateLatexData.datatypeDef;
  replacements['*********FUNCTION_TYPE*********'] = certificateLatexData.functionType;
  replacements['*********FUNCTION_DEF*********'] = certificateLatexData.functionDef;
  replacements['*********PROOF*********'] = certificateLatexData.proof;
  replacements['*********DATE*********'] = latexJsonBits.date;
  const replacements_regexp = new RegExp('(' +
    Object.keys(replacements).map(escape_regexp).join('|') + ')', 'g');
  // console.log(replacements_regexp);

  await fs.copy('latex_templates/en', args.outputDir);

  function fillTemplateAndSave(templateFilename:string) {
    const template = fs.readFileSync(
      path.join('latex_templates/en',templateFilename), { encoding: 'utf-8' });
    let output = template.replace(replacements_regexp,
      (_, matchedString) => { return replacements[matchedString]; });
    fs.writeFileSync(
      path.join(args.outputDir, templateFilename), output, {encoding: 'utf-8'});
  }

  fillTemplateAndSave('certificate.tex');
  fillTemplateAndSave('brouchure.tex');
  fillTemplateAndSave('thm.tex');
  fillTemplateAndSave('thy.tex');

  // function exec_out_fn(error : string, stdout : string, stderr :string) {
  //   if (error) {
  //     console.error(`exec error: ${error}`);
  //     throw new Error(error);
  //     // return;
  //   }
  //   console.log(`stdout: ${stdout}`);
  //   console.log(`stderr: ${stderr}`);
  // };

  console.log('Processing certificate...');
  child_process.execSync(`cd ${args.outputDir} && ` +
    `pdflatex -interaction nonstopmode -output-format pdf certificate.tex`,
    {stdio:[process.stdin, process.stdout, process.stderr]});
  child_process.execSync(`cd ${args.outputDir} && ` +
    `pdflatex -interaction nonstopmode -output-format pdf certificate.tex`,
    {stdio:[process.stdin, process.stdout, process.stderr]});
  child_process.execSync(`cd ${args.outputDir} && ` +
    `convert -density 400 certificate.pdf certificate_image.jpg`,
    {stdio:[process.stdin, process.stdout, process.stderr]});

  console.log('Processing thm...');
  child_process.execSync(`cd ${args.outputDir} && ` +
    `pdflatex -interaction nonstopmode -output-format pdf thm.tex`,
    {stdio:[process.stdin, process.stdout, process.stderr]});
  child_process.execSync(`cd ${args.outputDir} && ` +
    `pdflatex -interaction nonstopmode -output-format pdf thm.tex`,
    {stdio:[process.stdin, process.stdout, process.stderr]});
  child_process.execSync(`cd ${args.outputDir} && ` +
    `convert -gravity South -chop 0x4000 -density 400 "thm.pdf" "thm.jpg"`,
    {stdio:[process.stdin, process.stdout, process.stderr]});

  console.log('Processing thy...');
  child_process.execSync(`cd ${args.outputDir} && ` +
    `pdflatex -interaction nonstopmode -output-format pdf thy.tex`,
    {stdio:[process.stdin, process.stdout, process.stderr]});
  child_process.execSync(`cd ${args.outputDir} && ` +
    `pdflatex -interaction nonstopmode -output-format pdf thy.tex`,
    {stdio:[process.stdin, process.stdout, process.stderr]});
  child_process.execSync(`cd ${args.outputDir} && ` +
    `convert -gravity South -chop 0x1000 -density 400 "thy.pdf" "thy.jpg"`,
    {stdio:[process.stdin, process.stdout, process.stderr]});

  console.log('Processing brouchure...');
  child_process.execSync(`cd ${args.outputDir} && ` +
    `pdflatex -interaction nonstopmode -output-format pdf brouchure.tex`,
    {stdio:[process.stdin, process.stdout, process.stderr]});
  child_process.execSync(`cd ${args.outputDir} && ` +
    `pdflatex -interaction nonstopmode -output-format pdf brouchure.tex`,
    {stdio:[process.stdin, process.stdout, process.stderr]});

  console.log(`Output to: ${args.outputDir}`)
}

let args = yargs
    .option('configPath', {
        describe: 'Path to JSON file of questions to upload'
    })
    .option('inputJson', {
      describe: 'Use certificate JSON in this text file'
    })
    .option('inputCid', {
      describe: 'Certificate id'
    })
    .option('outputDir', {
      describe: 'Directory to write the output files to'
    })
    .default('configPath', 'build/config/config.json')
    .demandOption(['configPath', 'outputDir'],
      'Please provide at least --outputDir (and one of --input_cid or --inputJson).')
    .help()
    .argv;

main(args as any as Args)
  .then(() => {
    console.log('Success!');
  }).catch(e => {
    console.error('Failed: ', e.message);
  });