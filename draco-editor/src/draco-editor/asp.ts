const ASP_FORMAT = {
  brackets: [
    ["{", "}", "delimiter.curly"],
    ["[", "]", "delimiter.square"],
    ["(", ")", "delimiter.parenthesis"]
  ],

  keywords: ["not"],

  operators: [
    ":",
    "..",
    ":~",
    ":-",
    "|",
    ";",
    ",",
    "=",
    "!=",
    "<",
    "<=",
    ">",
    ">=",
    "+",
    "-",
    "/",
    "*",
    "@"
  ],

  // operators
  symbols: /([\.]{2})|([=><!:\|\+\-\~\*\/%,;]+)/,

  tokenizer: {
    root: [
      { include: "@whitespace" },

      // variables
      [/[A-Z][\w_]*('*)/, "tag"], // variable.name

      [
        /[a-zA-Z_][\w_]*('*)/,
        {
          cases: {
            "@keywords": "keyword",
            "@default": "identifier"
          }
        }
      ],

      // delimiters
      [/[\{\}\(\)\[\]]/, "@brackets"],
      [/\./, "delimiter"],

      // numbers
      [/[\-\+]?\d+\/[\-\+]?\d*[1-9]/, "number"],
      [/[\-\+]?\d+(\.\d+)?/, "number"],
      [
        /@symbols/,
        {
          cases: {
            "@operators": "keyword",
            "@default": "symbols"
          }
        }
      ],

      // strings
      [/"([^"\\]|\\.)*$/, "string.invalid"], // non-teminated string
      [/"/, "string", "@string"]
    ],

    whitespace: [
      [/[ \t\r\n]+/, "white"],
      [/\%.*$/, "comment"],
      [/\#.*$/, "comment"]
    ],

    string: [[/[^"]+/, "string"], [/"/, "string", "@pop"]]
  }
};

export default ASP_FORMAT;
