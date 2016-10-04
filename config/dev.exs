use Mix.Config

config :currexbot,
  env: :dev

config :logger,
  level: :debug

import_config "dev.secret.exs"
