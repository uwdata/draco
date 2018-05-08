import * as constraints from './all';

let output = "";

function updateOutput() {
  const contentElement = document.querySelector('#content');
  if (contentElement) {
    contentElement.textContent = output;
  }
}

let Module = Object.assign({
  preRun: <any>[],
  postRun: <any>[],
  print: <any>(function() {
    return function(text: string) {
      if (arguments.length > 1) { text = Array.prototype.slice.call(arguments).join(' '); }
      output += text + "\n";
    };
  })(),
  printErr: function(text: string) {
    if (arguments.length > 1) text = Array.prototype.slice.call(arguments).join(' ');
    if (text === "Calling stub instead of signal()") { return; }
    var prefix = "pre-main prep time: ";
    if (typeof text==="string" && prefix == text.slice(0, prefix.length)) { text = "Ready to go!" }
    output += text + "\n";
    updateOutput();
  },
  setStatus: <any>function(text: string) {
    output += text + "\n";
    updateOutput();
  },
  totalDependencies: <number>0,
  monitorRunDependencies: <any>function(left: number) {
    console.log(left);
    Module.totalDependencies = Math.max(Module.totalDependencies, left);
    Module.setStatus(left ? 'Preparing... (' + (Module.totalDependencies-left) + '/' + Module.totalDependencies + ')' : 'All downloads complete.');
  }
}, (<any>window).Module);

Module.setStatus('downloading...');

const contentElement = document.querySelector('#content');
if (contentElement) {
  contentElement.textContent = 'hello!';
}

function call() {
  const example = `
    % instance
    motive(harry).
    motive(sally).
    guilty(harry).

    % encoding
    innocent(Suspect) :- motive(Suspect), not guilty(Suspect).
    `
  let options = "";
  ((<any>window).Module).ccall('run', 'number', ['string', 'string'], [example, options])
}

const title = document.querySelector('#title');
if (title) {
  title.addEventListener('click', call);
}
updateOutput();
export const prog = constraints;

export default function run() {
  console.log(constraints);
}

(<any>window).Module = Module;
