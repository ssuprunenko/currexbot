use Mix.Config

config :currexbot,
  ecto_repos: [Currexbot.Repo],
  port: String.to_integer(System.get_env("PORT") || "4000")

import_config "#{Mix.env}.exs"
