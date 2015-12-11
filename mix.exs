defmodule Currexbot.Mixfile do
  use Mix.Project

  def project do
    [app: :currexbot,
     version: "0.0.2",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [
      applications: [:logger, :nadia],
      mod: {Currexbot, []}
    ]
  end

  defp deps do
    [
      {:nadia, "~> 0.3"},
      {:sweet_xml, "~> 0.5"},
      {:dogma, "~> 0.0", only: :dev},
      {:credo, "~> 0.2", only: [:dev, :test]}
    ]
  end
end
