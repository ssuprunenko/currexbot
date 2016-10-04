defmodule Currexbot.Mixfile do
  use Mix.Project

  def project do
    [app: :currexbot,
     version: "0.1.0",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [
      applications: [
        :postgrex,
        :ecto,
        :logger,
        :httpoison,
        :nadia,
        :botan,
        :cowboy,
        :plug
      ],
      mod: {Currexbot, []}
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 0.9.0"},
      {:nadia, github: "zhyu/nadia"},
      {:floki, "~> 0.10"},
      {:sweet_xml, "~> 0.6"},
      {:postgrex, "~> 0.12.1"},
      {:ecto, "~> 2.0.0"},
      {:linguist, "~> 0.1.5"},
      {:russian, "~> 0.1.0"},
      {:cowboy, "~> 1.0.4"},
      {:plug, "~> 1.2"},
      {:botan, github: "ssuprunenko/exBotan", branch: "update-deps"},
      {:credo, "~> 0.4", only: [:dev, :test]}
    ]
  end
end
