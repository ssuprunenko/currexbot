defmodule Currexbot.Bot do
  alias Nadia.Model.Message
  alias Nadia.Model.Chat
  alias Nadia.Model.User
  alias Currexbot.Currency

  @doc """
  handle incoming message
  """
  def handle_message(%Message{chat: %Chat{type: "private", id: chat_id}, text: text}) do
    handle_private_message(chat_id, text)
  end

  # fallback
  def handle_message(_), do: true

  defp handle_private_message(chat_id, "hello") do
    Nadia.send_message(chat_id, "yo")
  end

  defp handle_private_message(chat_id, "/me") do
    {:ok, %User{first_name: bot_name}} = Nadia.get_me
    env = Application.get_env(:currexbot, :env)
    reply = """
    #{bot_name} in #{env} mode.
    Current directory: #{System.cwd}
    """

    Nadia.send_message(chat_id, reply)
  end

  defp handle_private_message(chat_id, "/usd") do
    reply = Currency.get_rates("USD", "name")

    Nadia.send_message(chat_id, reply)
  end

  defp handle_private_message(chat_id, "/usd " <> sort_el) do
    reply = Currency.get_rates("USD", sort_el)

    Nadia.send_message(chat_id, reply)
  end

  defp handle_private_message(chat_id, "/eur") do
    reply = Currency.get_rates("EUR", "name")

    Nadia.send_message(chat_id, reply)
  end

  defp handle_private_message(chat_id, "/eur " <> sort_el) do
    reply = Currency.get_rates("EUR", sort_el)

    Nadia.send_message(chat_id, reply)
  end

  defp handle_private_message(chat_id, _) do
    Nadia.send_message(chat_id, "dunno")
  end
end
