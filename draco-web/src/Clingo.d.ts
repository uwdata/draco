declare module 'wasm-clingo' {
  const Clingo: (Module: any) => Promise<any>;
  export default Clingo;
}
