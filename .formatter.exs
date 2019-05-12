# Used by "mix format"
locals_without_parens = [
  command: 1,
  command: 2,
  match: 2,
  match: 3,
  redirect: 2,
  redirect: 3
]

[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: locals_without_parens,
  export: [locals_without_parens: locals_without_parens]
]
