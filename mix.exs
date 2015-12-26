defmodule Currexbot.Mixfile do
  use Mix.Project

  def project do
    [app: :currexbot,
     version: "0.0.3",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [
      applications: [:postgrex, :ecto, :logger, :httpoison, :nadia],
      mod: {Currexbot, []}
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 0.8.0"},
      {:nadia, "~> 0.3"},
      {:sweet_xml, "~> 0.5"},
      {:postgrex, ">= 0.0.0"},
      {:ecto, "~> 1.1"},
      {:dogma, "~> 0.0", only: :dev},
      {:credo, "~> 0.2", only: [:dev, :test]}
    ]
  end
end
