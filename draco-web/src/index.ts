import {constraints} from './all';

let output = "";

let Module = {
  preRun: [],
  postRun: [],
  print: (function() {
    return function(text: string) {
      if (arguments.length > 1) { text = Array.prototype.slice.call(arguments).join(' '); }
      output += text + "\n";
      console.log(output);
    };
  })(),
  totalDependencies: 0,
  ccall: (a: any, b:any, c:any, d:any) => {},
};

const example = `
% instance
motive(harry).
motive(sally).
guilty(harry).

% encoding
innocent(Suspect) :- motive(Suspect), not guilty(Suspect).
`

Module.ccall('run', 'number', ['string', 'string'], [example])

export const prog = constraints;

export default function run() {
  console.log(constraints);
}
