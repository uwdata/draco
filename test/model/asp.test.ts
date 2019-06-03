const { spawnSync } = require('child_process');
const path = require('path');

describe('Check ASP warnings', () => {
  test('No warnings', () => {
    const program = path.resolve(__dirname, '../../model/program/default.lp');
    const data = path.resolve(__dirname,'./data.lp');

    const output = spawnSync('clingo', ['-q', '--outf=2', data, program], { encoding: 'utf8' });

    expect(output.stderr).toEqual('');
  });
});
