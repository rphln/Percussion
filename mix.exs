defmodule Percussion.MixProject do
  use Mix.Project

  @version "0.10.0"
  @description "A command framework for Nostrum."

  def project do
    [
      description: @description,
      version: @version,
      app: :percussion,
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      elixir: "~> 1.8",
      deps: deps(),

      # Docs
      docs: docs(),
      name: "Percussion",
      source_url: "https://github.com/rphln/Percussion",
      homepage_url: "https://blindjoker.github.io/Percussion/"
    ]
  end

  def package do
    [
      licenses: ["MIT"],
      maintainers: ["Raphael Nepomuceno"],
      links: %{
        "GitHub" => "https://github.com/rphln/Percussion/",
        "Docs" => "https://blindjoker.github.io/Percussion/"
      }
    ]
  end

  defp deps do
    [
      {:nostrum, "~> 0.4", runtime: false},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:credo, "~> 1.5-pre", only: [:dev, :test], runtime: false}
    ]
  end

  def docs do
    [
      main: "readme",
      groups_for_modules: groups_for_modules(),
      source_ref: "v#{@version}",
      source_url: "https://github.com/rphln/Percussion",
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
