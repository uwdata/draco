import nodeResolve from "rollup-plugin-node-resolve";
import commonjs from "rollup-plugin-commonjs";
import builtins from "rollup-plugin-node-builtins";

export default {
  input: "build/index.js",
  output: {
    file: "build/draco.js",
    format: "cjs",
    sourcemap: true
  },
  plugins: [nodeResolve(), commonjs(), builtins()]
};
