

declare namespace Example {

  export interface TOptions {
    name: str
    aliases: Array<str>
  }

  export interface TClosure {
    options: Example.TOptions
    checkName: (name: string) => bool;
  }
}
