const { spawnSync } = require("child_process");
const path = require("path");

describe("Check ASP warnings", () => {
  test("No warnings", () => {
    const program = path.resolve(__dirname, "../../model/program/check.lp");

    const output = spawnSync("clingo", ["-q", "--outf=2", program], {
      encoding: "utf8"
    });

    expect(output.stderr).toEqual("");
  });
});
