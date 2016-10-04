use Mix.Config

config :currexbot,
  env: :prod

config :logger,
	level: :info

import_config "prod.secret.exs"
