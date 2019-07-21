defmodule Percussion.MixProject do
  use Mix.Project

  @version "0.5.0"
  @description "A command framework for Nostrum."

  def project do
    [
      description: @description,
      version: @version,
      app: :percussion,
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,

      # Deps
      elixir: "~> 1.8",
      deps: deps(),

      # Docs
      docs: docs(),

      # Docs
      name: "Percussion",
      source_url: "https://github.com/BlindJoker/Percussion",
      homepage_url: "https://blindjoker.github.io/Percussion/"
    ]
  end

  def package do
    [
      licenses: ["MIT"],
      maintainers: ["Raphael Nepomuceno"],
      links: %{
        "GitHub" => "https://github.com/BlindJoker/Percussion/",
        "Docs" => "https://blindjoker.github.io/Percussion/"
      }
    ]
  end

  defp deps do
    [
      {:nostrum, "~> 0.3", runtime: false},

      # Development dependencies.
      {:credo, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.20", only: :dev, runtime: false}
    ]
  end

  def docs do
    [
      main: "readme",
      groups_for_modules: groups_for_modules(),
      source_ref: "v#{@version}",
      source_url: "https://github.com/BlindJoker/Percussion",
      extras: [
        "README.md"
      ]
    ]
  end

  defp groups_for_modules do
    [
      Declarative: [
        Percussion.Declarative,
        Percussion.Declarative.Command,
        Percussion.Declarative.Pipe,
        Percussion.Declarative.Router,
        Percussion.Declarative.Dispatcher
      ],
      Utils: [
        Percussion.Converters,
        Percussion.Decorators
      ]
    ]
  end
end
