# CurrexBot

Telegram bot written in Elixir.

## Installation

```sh
# Install Elixir deps
mix deps.get

# Get new Telegram bot token
https://telegram.me/BotFather

# Set up the secrets
cp config/dev.secret.exs.example config/dev.secret.exs
vim config/dev.secret.exs

# Run the tests
mix test

# Run the app in console mode
iex -S mix

# Or run without console
mix run --no-halt
```

## Deploying on Dokku
Check [DEPLOY.md](DEPLOY.md) guide.

```sh
# Run custom command on Dokku (on server)
dokku run APP_NAME mix ecto.migrate

# Set ENV variable
dokku config:set APP_NAME BOTAN_TOKEN=secret_key

# Run seeds
dokku run APP_NAME mix run priv/repo/seeds.exs

# Open iex console
dokku run APP_NAME iex -S mix
```
