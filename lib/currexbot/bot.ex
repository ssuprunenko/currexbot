defmodule Currexbot.Bot do
  @moduledoc """
  Handles commands from a Telegram chat
  """
  alias Nadia.Model.Message
  alias Nadia.Model.Chat
  alias Nadia.Model.ReplyKeyboardMarkup
  alias Currexbot.Bank
  alias Currexbot.Currency
  alias Currexbot.User
  import Enum, only: [at: 2]

  @usd_list ["/usd", "Курс доллара 💵"]
  @eur_list ["/eur", "Курс евро 💶"]

  @doc """
  Handle incoming message
  """
  def handle_message(%Message{chat: %Chat{type: "private", id: chat_id}, text: text}) do
    user = User.find_or_create_by_chat_id chat_id

    handle_private_message(user, chat_id, text)
  end

  # Fallback
  def handle_message(_), do: true

  # Ping
  defp handle_private_message(_user, chat_id, "ping") do
    Nadia.send_message(chat_id, "pong")
  end

  defp handle_private_message(_user, chat_id, "/me") do
    {:ok, %Nadia.Model.User{first_name: bot_name}} = Nadia.get_me
    env = Application.get_env(:currexbot, :env)
    reply = """
    #{bot_name} in #{env} mode.
    Current directory: #{System.cwd}
    """

    Nadia.send_message(chat_id, reply)
  end

  # Sends actual USD rates to the chat sorted by a bank's name.
  defp handle_private_message(user, chat_id, text) when text in @usd_list do
    reply = Currency.get_rates(user, "USD")

    Nadia.send_message(chat_id, reply, reply_markup: default_kbd)
  end

  # Sends actual USD rates to the chat sorted by buy value in descending order.
  defp handle_private_message(user, chat_id, "/usd " <> sort_el) do
    reply = Currency.get_rates(user, "USD", sort_el)

    Nadia.send_message(chat_id, reply)
  end

  # Sends actual EUR rates to the chat sorted by a bank's name.
  defp handle_private_message(user, chat_id, text) when text in @eur_list do
    reply = Currency.get_rates(user, "EUR")

    Nadia.send_message(chat_id, reply, reply_markup: default_kbd)
  end

  # Sends actual EUR rates to the chat sorted by buy value in descending order.
  defp handle_private_message(user, chat_id, "/eur " <> sort_el) do
    reply = Currency.get_rates(user, "EUR", sort_el)

    Nadia.send_message(chat_id, reply)
  end

  #
  # Settings commands
  #
  defp handle_private_message(_user, chat_id, "Настройки 🔧") do
    Nadia.send_message(chat_id, "Ваши текущие настройки:", reply_markup: settings_kbd)
  end

  defp handle_private_message(_user, chat_id, "/settings") do
    Nadia.send_message(chat_id, "Ваши текущие настройки:", reply_markup: settings_kbd)
  end

  defp handle_private_message(user, chat_id, "Избранные банки ⭐️") do
    reply =
      case user.fav_banks do
        [] -> "У вас нет избранных банков"
        _ -> "Ваши избранные банки:\n" <> Enum.join(user.fav_banks, "\n")
      end

    Nadia.send_message(chat_id, reply, reply_markup: fav_banks_kbd)
  end

  defp handle_private_message(user, chat_id, "Доступные банки") do
    banks = Bank.available_in_city
    reply = Enum.join(banks, "\n")

    Nadia.send_message(chat_id, reply, reply_markup: fav_banks_kbd)
  end

  defp handle_private_message(user, chat_id, "Добавить банк") do
    reply = "Выберите банк:"

    Nadia.send_message(chat_id, reply, reply_markup: banks_to_add_kbd(user))
  end

  defp handle_private_message(user, chat_id, "Удалить банк") do
    reply = "Выберите банк:"

    Nadia.send_message(chat_id, reply, reply_markup: banks_to_remove_kbd(user))
  end

  defp handle_private_message(user, chat_id, "Очистить избранное") do
    user_change = Ecto.Changeset.change user, fav_banks: []
    Currexbot.Repo.update user_change

    user = User.find_or_create_by_chat_id chat_id
    handle_private_message(user, chat_id, "Избранные банки ⭐️")
  end

  defp handle_private_message(user, chat_id, "⭐ " <> bank) do
    user_change = Ecto.Changeset.change user, fav_banks: user.fav_banks ++ [bank]
    Currexbot.Repo.update user_change

    user = User.find_or_create_by_chat_id chat_id
    handle_private_message(user, chat_id, "Избранные банки ⭐️")
  end

  defp handle_private_message(user, chat_id, "❌ " <> bank) do
    user_change = Ecto.Changeset.change user, fav_banks: user.fav_banks -- [bank]
    Currexbot.Repo.update user_change

    user = User.find_or_create_by_chat_id chat_id
    handle_private_message(user, chat_id, "Избранные банки ⭐️")
  end

  # Exchange rates commands
  defp handle_private_message(_user, chat_id, _) do
    Nadia.send_message(chat_id, "Выберите валюту:", reply_markup: default_kbd)
  end

  # Keyboards
  defp default_kbd do
    %ReplyKeyboardMarkup{keyboard: [
                          [at(@usd_list, 1)],
                          [at(@eur_list, 1)],
                          ["Настройки 🔧"]
                         ],
                         resize_keyboard: true,
                         one_time_keyboard: true}
  end

  defp settings_kbd do
    %ReplyKeyboardMarkup{keyboard: [
                          ["Избранные банки ⭐️"],
                          ["Ваш город 🏙"],
                          ["Главное меню"]
                         ],
                         resize_keyboard: true,
                         one_time_keyboard: true}
  end

  defp fav_banks_kbd do
    %ReplyKeyboardMarkup{keyboard: [
                          ["Доступные банки"],
                          ["Добавить банк"],
                          ["Удалить банк"],
                          ["Очистить избранное"],
                          ["Главное меню"]
                         ],
                         resize_keyboard: true,
                         one_time_keyboard: true}
  end

  defp banks_to_add_kbd(user, city_code \\ "7801") do
    banks = Bank.available_in_city(city_code) -- user.fav_banks
    banks_cmds = Enum.map(banks, fn(x) -> ["⭐ " <> x] end)
    buttons = [["Главное меню"]] ++ banks_cmds

    %ReplyKeyboardMarkup{keyboard: buttons,
                         resize_keyboard: true,
                         one_time_keyboard: true}
  end

  defp banks_to_remove_kbd(user, city_code \\ "7801") do
    banks = Enum.map(user.fav_banks, fn(x) -> ["❌ " <> x] end)
    buttons = [["Главное меню"]] ++ banks

    %ReplyKeyboardMarkup{keyboard: buttons,
                         resize_keyboard: true,
                         one_time_keyboard: true}
  end
end
