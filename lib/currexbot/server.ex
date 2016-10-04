defmodule Currexbot.Server do
  use Plug.Router
  require Logger

  plug Plug.Logger
  plug :match
  plug :dispatch

  def init(options) do
    options
  end

  def start_link do
    {:ok, _} = Plug.Adapters.Cowboy.http Currexbot.Server, []
  end

  # For Uptime Monitoring service
  get "/ping" do
    conn
    |> send_resp(200, "pong")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
