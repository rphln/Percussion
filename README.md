# 🥁 Percussion

Percussion is a command framework for [Nostrum]. It is based on the concept of
transformation pipelines for command requests, being loosely inspired by Plug.

  [Nostrum]: https://github.com/Kraigie/nostrum

The documentation can be found [here]. If you're looking for examples, see [Katsuragi].

  [here]: https://blindjoker.github.io/Percussion
  [Katsuragi]: https://github.com/BlindJoker/Katsuragi

## About the pipeline.

Chaining functions is the main way dealing with command requests (i.e., calls) in
Percussion.

The pipeline is composed of a list of steps that are called in order, which are simply
request to request functions:

```elixir
def ping(request) do
  reply(request, "Pong!")
end
```

Additionally, steps have the ability to stop the whole pipeline prematurely by calling
`Percussion.Request.halt/1` on the request; this may be used, for example, to handle
errors that occur in the middle of the pipeline process.

## Installation

At this moment, Percussion is highly volatile; if you're feeling adventurous and want to
try it, simply add it as a GitHub dependency.

```elixir
def deps do
  [
    {:percussion, github: "BlindJoker/Percussion"}
  ]
end
```

## Acknowledgements

Percussion borrows some of its code, either verbatim or as inspiration, from the
[nosedrum] library, which is licensed under the ISC license. See their repository for
more information.

  [nosedrum]: https://github.com/jchristgit/nosedrum

## License

This project is licensed under the [MIT] license.

  [MIT]: https://opensource.org/licenses/MIT
