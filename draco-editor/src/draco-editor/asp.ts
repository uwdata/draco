export const ASP_FORMAT = {
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

export const ASP_THEME = {
	base: 'vs', // can also be vs-dark or hc-black
	inherit: true, // can also be false to completely replace the builtin rules
	rules: [
    { token: "comment", foreground: "87a1c4" },
    { token: "number", foreground: "256fd1"},
    { token: "identifier", foreground: "586677" },
    { token: "keyword", foreground: "0090ff"},
    { token: "string", foreground: "7c71f2"}
  ],
  colors: {
    "editorCursor.foreground": "#586677",
    "editor.lineHighlightBackground": "#f9fcff",
  }
}

export default ASP_FORMAT;
