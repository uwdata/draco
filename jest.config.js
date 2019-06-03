const { defaults } = require("jest-config");

module.exports = {
  transform: {
    "^.+\\.tsx?$": "ts-jest"
  },
  moduleFileExtensions: [...defaults.moduleFileExtensions, "ts", "tsx", "lp"],
  setupFiles: ["jest-canvas-mock"],
  setupFilesAfterEnv: ["jest-extended"]
};
