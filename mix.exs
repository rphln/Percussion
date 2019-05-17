defmodule Percussion.MixProject do
  use Mix.Project

  def project do
    [
      app: :percussion,
      version: "0.1.1",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/BlindJoker/Percussion",
      homepage_url: "https://github.com/BlindJoker/Percussion",
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [],
      extra_applications: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nostrum, "~> 0.3"},

      # Development dependencies.
      {:ex_doc, "~> 0.20", only: :dev, runtime: false},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end
end
