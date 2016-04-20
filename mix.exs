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
      {:nadia, github: "zhyu/nadia"},
      {:floki, "~> 0.8"},
      {:sweet_xml, "~> 0.6"},
      {:postgrex, ">= 0.0.0"},
      {:ecto, "~> 2.0.0-rc.1"},
      {:credo, "~> 0.3", only: [:dev, :test]}
    ]
  end
end
