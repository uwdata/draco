import nodeResolve from 'rollup-plugin-node-resolve';
import commonjs from 'rollup-plugin-commonjs';

export default {
  input: "build/src/index.js",
  output: {
    file: "build/draco.js",
    format: "umd",
    sourcemap: true,
    name: "draco",
    exports: "named",
    external: ["path", "fs", "crypto"]
  },
  "plugins": [
    nodeResolve(),
    commonjs()
  ]
};
