# 🥁 Percussion

[![Build Status](https://travis-ci.org/BlindJoker/Percussion.svg?branch=master)](https://travis-ci.org/BlindJoker/Percussion)

`Percussion` is a command framework for use with the [`Nostrum`](https://github.com/Kraigie/nostrum) library. Its syntax is loosely inspired by Plug, and it aims to provide a somewhat clean interface without relying too much on macro magic.

The documentation can be found at https://blindjoker.github.io/Percussion. If you're looking for examples, [`Katsuragi`](https://github.com/BlindJoker/Katsuragi) is the main target of this library at the moment.

## Installation

At this moment, `Percussion` is not fully fit for public use, and as such is not available in Hex. If you're feeling adventurous and want to try it, simply add it as a GitHub dependency.

```elixir
def deps do
  [
    {:percussion, github: "BlindJoker/Percussion"}
  ]
end
```

## Acknowledgements

Percussion borrows some of its code, either verbatim or as inspiration, from the [`nosedrum`](https://github.com/jchristgit/nosedrum) library, which is licensed under the ISC license. See their repository for more information.

## License

This project is licensed under the [MIT](https://github.com/BlindJoker/Percussion/blob/master/LICENSE) license.
