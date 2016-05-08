use Mix.Config

config :nadia,
  token: System.get_env("TELEGRAM_BOT_TOKEN")

config :botan,
  token: System.get_env("BOTAN_TOKEN")

config :currexbot, Currexbot.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: 20
