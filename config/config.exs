use Mix.Config

config :currexbot, ecto_repos: [Currexbot.Repo]

import_config "#{Mix.env}.exs"
