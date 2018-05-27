declare module 'wasm-clingo' {
  const Clingo: (Module: any) => Promise<any>;
  namespace Clingo {}
  export = Clingo;
}
