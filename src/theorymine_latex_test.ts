import * as theorymine_latex from './theorymine_latex';
import { expect } from 'chai';

describe('Testing TheoryMine Latex JSON data management', function() {

  it('Simple test', function() {
    const exampleThmJson = {
      date: '6 Nov 2017',
      thm_title: 'Straley&#39;s Theorem',
      thm_body: 'f<sub>&beta;&omega;</sub>(x, Suc(y)) = Suc(f<sub>&beta;&omega;</sub>(x, y))',
      proof_body: 'Proof outline: induction and rippling',
      thy_title: 'T_13-T_13__f_81',
      thy_body: '<table><tr><td align="center" width="100%">\n  T<sub>14</sub> = C<sub>z</sub>(Bool) |  C<sub>y</sub>(T<sub>14</sub>, Bool)\n<br>\n<br>\nf<sub>&beta;&omega;</sub> : T<sub>14</sub> &times;  &#8469; &#8594; &#8469;\n</td></tr></table>\n<table>\n<tr><td width="48%" align="right">\n  f<sub>&beta;&omega;</sub>(C<sub>z</sub>(x), y)\n</td><td width="4%" align="center">=</td><td width="48%" align="left">\n  y\n</td></tr>\n<tr><td width="48%" align="right">\n  f<sub>&beta;&omega;</sub>(C<sub>y</sub>(x, y), z)\n</td><td width="4%" align="center">=</td><td width="48%" align="left">\n  Suc(Suc(Suc(Suc(Suc(f<sub>&beta;&omega;</sub>(x, z))))))\n</td></tr>\n</table>\n\n'
    };

    let htmlified_title = theorymine_latex.formulaToLatex(exampleThmJson.thm_title);
    expect(htmlified_title).to.equal('Straley\'s Theorem');
    let thy_parts = theorymine_latex.thyToLatex(exampleThmJson.thy_body);
    expect(thy_parts.datatypeDef).to.equal('T_{14}&=&C_{z}(Bool) |  C_{y}(T_{14}, Bool)');
    expect(thy_parts.functionType).to.equal('f_{\\beta\\o}: T_{14}\\times  \\nat  \\rightarrow \\nat');
    expect(thy_parts.functionDef).to.equal(
      'f_{\\beta\\o}(C_{z}(x), y)&=&y\\\\' +
      'f_{\\beta\\o}(C_{y}(x, y), z)&=&Suc(Suc(Suc(Suc(Suc(f_{\\beta\\o}(x, z))))))');
  });
});
