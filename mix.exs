defmodule Percussion.MixProject do
  use Mix.Project

  def project do
    [
      description: "A command framework for Nostrum.",
      version: "0.3.0",
      app: :percussion,
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,

      # Deps
      elixir: "~> 1.8",
      deps: deps(),

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
end
