defmodule Currexbot.Bot do
  @moduledoc """
  Handles commands from a Telegram chat
  """
  alias Nadia.Model.Message
  alias Nadia.Model.Chat
  alias Nadia.Model.User
  alias Currexbot.Currency

  @doc """
  Handle incoming message
  """
  def handle_message(%Message{chat: %Chat{type: "private", id: chat_id}, text: text}) do
    handle_private_message(chat_id, text)
  end

  # Fallback
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

  # Sends actual USD rates to the chat sorted by a bank's name.
  defp handle_private_message(chat_id, "/usd") do
    reply = Currency.get_rates("USD")

    Nadia.send_message(chat_id, reply)
  end

  # Sends actual USD rates to the chat sorted by buy value in descending order.
  defp handle_private_message(chat_id, "/usd " <> sort_el) do
    reply = Currency.get_rates("USD", sort_el)

    Nadia.send_message(chat_id, reply)
  end

  # Sends actual EUR rates to the chat sorted by a bank's name.
  defp handle_private_message(chat_id, "/eur") do
    reply = Currency.get_rates("EUR")

    Nadia.send_message(chat_id, reply)
  end

  # Sends actual EUR rates to the chat sorted by buy value in descending order.
  defp handle_private_message(chat_id, "/eur " <> sort_el) do
    reply = Currency.get_rates("EUR", sort_el)

    Nadia.send_message(chat_id, reply)
  end

  defp handle_private_message(chat_id, _) do
    Nadia.send_message(chat_id, "dunno")
  end
end
