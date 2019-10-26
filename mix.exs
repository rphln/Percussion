defmodule Percussion.MixProject do
  use Mix.Project

  @version "0.8.0"
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
      {:nostrum, "~> 0.4", runtime: false},

      # Development dependencies.
      {:credo, "~> 1.1", only: :dev, runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
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
      Utils: [
        Percussion.Converters,
        Percussion.Decorators
      ]
    ]
  end
end
