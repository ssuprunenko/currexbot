defmodule Currexbot.Server do
  use Plug.Router
  require Logger
  alias Currexbot.Bot

  plug Plug.Logger
  plug :match
  plug :dispatch

  def init(options) do
    options
  end

  def start_link do
    {:ok, _} = Plug.Adapters.Cowboy.http Currexbot.Server, [], port: Application.get_env(:currexbot, :port)
  end

  # For Uptime Monitoring service
  get "/ping" do
    conn
    |> send_resp(200, "pong")
  end

  # Handle Telegram Webhook
  post "/messages" do
    with {:ok, body, _} <- read_body(conn),
         {:ok, %{message: msg}} <- Poison.decode(body, keys: :atoms),
         message <- Nadia.Parser.parse_result(msg, ""),
      do: handle_message(message)

    send_resp(conn, 201, "Created")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  defp handle_message(message) do
    Bot.handle_message(message)
    Logger.info("Message #{message.text} from #{message.from.username}")
  end
end
