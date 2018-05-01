export default {
  input: "build/index.js",
  output: {
    file: "build/draco.js",
    format: "umd",
    sourcemap: true,
    name: "draco",
    exports: "named"
  }
};
