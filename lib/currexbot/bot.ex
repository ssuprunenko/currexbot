defmodule Currexbot.Bot do
  @moduledoc """
  Handles commands from a Telegram chat
  """
  alias Nadia.Model.Message
  alias Nadia.Model.Chat
  alias Nadia.Model.Location
  alias Nadia.Model.ReplyKeyboardMarkup
  alias Currexbot.Bank
  alias Currexbot.City
  alias Currexbot.Currency
  alias Currexbot.Repo
  alias Currexbot.User
  import Enum, only: [at: 2]

  @usd_list ["/usd", "Курс доллара 💵"]
  @eur_list ["/eur", "Курс евро 💶"]
  @cb_list ["/cb", "Курсы ЦБ 🏦"]
  @current_city_list ["/city", "Установить вручную"]
  @settings_list ["/settings", "Настройки 🔧"]
  @help_list ["/start", "/help", "О боте 👾"]
  @main_menu "Главное меню 🚩"

  @doc """
  Handle incoming message
  """
  def handle_message(%Message{
    chat: %Chat{type: "private", id: chat_id},
    text: text,
    location: nil}) do
    user = User.find_or_create_by_chat_id(chat_id)

    handle_private_message(user, chat_id, text)
  end

  def handle_message(%Message{
    chat: %Chat{type: "private", id: chat_id},
    location: %Location{latitude: lat, longitude: long}}) do
    user = User.find_or_create_by_chat_id(chat_id)

    reply =
      case City.geocode(lat, long) do
        {:ok, city} ->
          unless user.city == city do
            changeset = User.changeset(user, %{city_id: city.id})
            Repo.update!(changeset)
          end
          "Ваш текущий город — *#{city.name}*"
        {:error, _msg} ->
          "Извините, ваш город пока не поддерживается"
      end

    Nadia.send_message(chat_id, reply, parse_mode: "Markdown", reply_markup: default_kbd)
  end

  # Fallback
  def handle_message(_), do: true

  # Ping
  defp handle_private_message(_user, chat_id, "ping") do
    Nadia.send_message(chat_id, "pong")
  end

  # Start and Help messages
  defp handle_private_message(_user, chat_id, text) when text in @help_list do
    reply = """
    Бот показывает актуальные курсы доллара и евро в банках вашего города, а также курсы валют ЦБ на сегодняшний день.
    В настройках вы можете выбрать ваш текущий город и добавить банки в избранное. По умолчанию показываются курсы всех банков Москвы.
    Провайдер данных — сервис http://kovalut.ru

    Используйте команды /usd и /eur, чтобы посмотреть курсы доллара и евро на текущий момент.

    По любым вопросам, связанным с работой бота, пишите на адрес suprunenko.s@gmail.com
    Надеюсь, этот бот будет вам полезен.
    """

    Nadia.send_message(chat_id, reply, reply_markup: default_kbd)
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

    Nadia.send_message(chat_id, reply)
  end

  # Sends actual EUR rates to the chat sorted by a bank's name.
  defp handle_private_message(user, chat_id, text) when text in @eur_list do
    reply = Currency.get_rates(user, "EUR")

    Nadia.send_message(chat_id, reply)
  end

  # Sends actual Central Bank rates to the chat.
  defp handle_private_message(user, chat_id, text) when text in @cb_list do
    rates = Currency.get_cb_rates(user)
    reply = """
    Доллар #{rates.usd}
    Евро #{rates.eur}
    """

    Nadia.send_message(chat_id, reply)
  end

  #
  # Settings commands
  #
  defp handle_private_message(user, chat_id, text) when text in @settings_list do
    reply = """
    Ваши текущие настройки:
    Город: #{user.city.name}
    """

    Nadia.send_message(chat_id, reply, reply_markup: settings_kbd)
  end

  #
  # Manage favorite banks
  #
  defp handle_private_message(user, chat_id, "Избранные банки ⭐️") do
    reply =
      case user.fav_banks do
        [] -> "У вас нет избранных банков"
        _ -> "Ваши избранные банки:\n" <> Enum.join(user.fav_banks, "\n")
      end

    Nadia.send_message(chat_id, reply, reply_markup: fav_banks_kbd)
  end

  defp handle_private_message(user, chat_id, "Доступные банки") do
    banks = Bank.available_in_city(user.city.code)
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
    user_change = Ecto.Changeset.change(user, fav_banks: [])
    Repo.update(user_change)

    user = User.find_or_create_by_chat_id(chat_id)
    handle_private_message(user, chat_id, "Избранные банки ⭐️")
  end

  defp handle_private_message(user, chat_id, "⭐ " <> bank) do
    user_change = Ecto.Changeset.change(user, fav_banks: user.fav_banks ++ [bank])
    Repo.update(user_change)

    user = User.find_or_create_by_chat_id(chat_id)
    handle_private_message(user, chat_id, "Избранные банки ⭐️")
  end

  defp handle_private_message(user, chat_id, "❌ " <> bank) do
    user_change = Ecto.Changeset.change user, fav_banks: user.fav_banks -- [bank]
    Repo.update user_change

    user = User.find_or_create_by_chat_id(chat_id)
    handle_private_message(user, chat_id, "Избранные банки ⭐️")
  end

  #
  # Manage current city
  #
  defp handle_private_message(user, chat_id, "Изменить город 🏙") do
    city = user.city.name
    reply = """
    Ваш текущий город — *#{city}*
    """

    Nadia.send_message(chat_id, reply, parse_mode: "Markdown", reply_markup: detect_city_kbd)
  end

  defp handle_private_message(user, chat_id, "/city " <> city_name) do
    city = Repo.get_by(City, name: city_name)
    reply =
      case city do
        %City{} ->
          unless user.city == city do
            changeset = User.changeset(user, %{city_id: city.id})
            Repo.update!(changeset)
          end
          "Ваш текущий город — *#{city_name}*"
        nil ->
          "Извините, ваш город пока не поддерживается"
      end

    Nadia.send_message(chat_id, reply, parse_mode: "Markdown", reply_markup: default_kbd)
  end

  defp handle_private_message(user, chat_id, text) when text in @current_city_list do
    city = user.city.name
    reply = """
    Ваш текущий город — *#{city}*
    Команда для изменения города:
    `/city Санкт-Петербург`
    """

    Nadia.send_message(chat_id, reply, parse_mode: "Markdown", reply_markup: detect_city_kbd)
  end

  # Default fallback function
  defp handle_private_message(_user, chat_id, _) do
    Nadia.send_message(chat_id, "Выберите валюту:", reply_markup: default_kbd)
  end

  #
  # Custom Keyboards
  #
  #
  # Default keyboard
  defp default_kbd do
    %ReplyKeyboardMarkup{keyboard: [
                          [at(@usd_list, 1)],
                          [at(@eur_list, 1)],
                          [at(@cb_list, 1)],
                          [at(@settings_list, 1)],
                          [at(@help_list, 2)]
                         ],
                         resize_keyboard: true,
                         one_time_keyboard: true}
  end

  # Settings keyboard
  defp settings_kbd do
    %ReplyKeyboardMarkup{keyboard: [
                          ["Изменить город 🏙"],
                          ["Избранные банки ⭐️"],
                          [@main_menu]
                         ],
                         resize_keyboard: true,
                         one_time_keyboard: true}
  end

  # Fav banks keyboard
  defp fav_banks_kbd do
    %ReplyKeyboardMarkup{keyboard: [
                          ["Доступные банки"],
                          ["Добавить банк"],
                          ["Удалить банк"],
                          ["Очистить избранное"],
                          [@main_menu]
                         ],
                         resize_keyboard: true,
                         one_time_keyboard: true}
  end

  defp banks_to_add_kbd(user) do
    banks = Bank.available_in_city(user.city.code) -- user.fav_banks
    banks_cmds = Enum.map(banks, fn(x) -> ["⭐ " <> x] end)
    buttons = [[@main_menu]] ++ banks_cmds

    %ReplyKeyboardMarkup{keyboard: buttons,
                         resize_keyboard: true,
                         one_time_keyboard: true}
  end

  defp banks_to_remove_kbd(user) do
    banks = Enum.map(user.fav_banks, fn(x) -> ["❌ " <> x] end)
    buttons = [[@main_menu]] ++ banks

    %ReplyKeyboardMarkup{keyboard: buttons,
                         resize_keyboard: true,
                         one_time_keyboard: true}
  end

  # Current city keyboard
  defp detect_city_kbd do
    %ReplyKeyboardMarkup{
      keyboard: [
        ["Установить вручную"],
        [%Nadia.Model.KeyboardButton{text: "Определить автоматически", request_location: true}],
        [@main_menu]
      ],
      resize_keyboard: true,
      one_time_keyboard: true
    }
  end
end
