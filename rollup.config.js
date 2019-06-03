import commonjs from "rollup-plugin-commonjs";
import json from "rollup-plugin-json";
import builtins from "rollup-plugin-node-builtins";
import nodeResolve from "rollup-plugin-node-resolve";

export default {
  input: "./build/index.js",
  output: {
    file: "./build/bundle.js",
    format: "cjs",
    sourcemap: true
  },
  plugins: [nodeResolve(), commonjs(), builtins(), json()]
};
