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

# Production
```sh
# Compile app in Production mode
MIX_ENV=prod mix compile

# Build a production exrm release
MIX_ENV=prod mix release

# Run release in console mode
rel/currexbot/bin/currexbot console

# Or run release as background process
rel/currexbot/bin/currexbot start
```
