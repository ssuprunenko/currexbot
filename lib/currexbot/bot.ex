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
  alias Currexbot.Command
  alias Currexbot.Currency
  alias Currexbot.Repo
  alias Currexbot.User
  import Currexbot.Command

  #
  # Commands
  #
  @settings  %Command{cmd: ["/settings", "/lang"], ru: "Настройки 🔧", en: "Settings 🔧"}
  @about     %Command{cmd: ["/start", "/help"], ru: "О боте 👾", en: "Help 👾"}
  @lang      %Command{cmd: "/lang", ru: "Switch to English 🌎", en: "Переключиться на русский 🌍"}
  @main_menu %Command{ru: "Главное меню 🚩", en: "Main menu 🚩"}

  @usd %Command{cmd: "/usd", ru: "Курс доллара 💵", en: "USD rates 💵"}
  @eur %Command{cmd: "/eur", ru: "Курс евро 💶", en: "Euro rates 💶"}
  @cb  %Command{cmd: "/cb", ru: "Курсы ЦБ 🏦", en: "CBR rates 🏦"}

  @city_manual %Command{cmd: "/city", ru: "Установить вручную", en: "Manually set"}
  @city_auto   %Command{ru: "Определить автоматически", en: "Send my location"}
  @edit_city   %Command{ru: "Изменить город 🏙", en: "Edit my city 🏙"}

  @fav_banks %Command{ru: "Избранные банки ⭐️", en: "Favorite banks ⭐️"}
  @all_banks %Command{ru: "Доступные банки", en: "Available banks"}
  @add_bank  %Command{ru: "Добавить банк", en: "Add bank"}
  @rm_bank   %Command{ru: "Удалить банк", en: "Remove bank"}
  @rm_fav_banks %Command{ru: "Очистить избранное", en: "Clear all favorites"}

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
          I18n.t!(user.language, "city.current", city: city.name)
        {:error, _msg} ->
          I18n.t!(user.language, "city.not_support")
      end

    Nadia.send_message(chat_id, reply, parse_mode: "Markdown", reply_markup: default_kbd(user.language))
  end

  # Fallback
  def handle_message(_), do: true

  # Ping
  defp handle_private_message(_user, chat_id, "ping") do
    Nadia.send_message(chat_id, "pong")
  end

  # Start and Help messages
  defp handle_private_message(user, chat_id, text) when text in unquote(values(@about)) do
    reply = I18n.t!(user.language, "about_msg")

    Nadia.send_message(chat_id, reply, parse_mode: "Markdown", reply_markup: default_kbd(user.language))
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
  defp handle_private_message(user, chat_id, text) when text in unquote(values(@usd)) do
    reply = Currency.get_rates(user, "USD")

    Nadia.send_message(chat_id, reply)
  end

  # Sends actual EUR rates to the chat sorted by a bank's name.
  defp handle_private_message(user, chat_id, text) when text in unquote(values(@eur)) do
    reply = Currency.get_rates(user, "EUR")

    Nadia.send_message(chat_id, reply)
  end

  # Sends actual Central Bank rates to the chat.
  defp handle_private_message(user, chat_id, text) when text in unquote(values(@cb)) do
    rates = Currency.get_cb_rates(user)
    reply = """
    #{I18n.t!(user.language, "cb.usd", rates: rates.usd)}
    #{I18n.t!(user.language, "cb.eur", rates: rates.eur)}
    """

    Nadia.send_message(chat_id, reply)
  end

  #
  # Settings commands
  #
  defp handle_private_message(user, chat_id, text) when text in unquote(values(@settings)) do
    reply = """
    #{I18n.t!(user.language, "settings.current")}
    #{I18n.t!(user.language, "settings.city", city: user.city.name)}
    #{I18n.t!(user.language, "settings.lang")}
    """

    Nadia.send_message(chat_id, reply, reply_markup: settings_kbd(user.language))
  end

  #
  # Manage favorite banks
  #
  defp handle_private_message(user, chat_id, text) when text in unquote(values(@fav_banks)) do
    reply =
      case user.fav_banks do
        [] -> I18n.t!(user.language, "banks.no_fav")
        _ -> I18n.t!(user.language, "banks.your_fav") <> Enum.join(user.fav_banks, "\n")
      end

    Nadia.send_message(chat_id, reply, reply_markup: fav_banks_kbd(user.language))
  end

  defp handle_private_message(user, chat_id, text) when text in unquote(values(@all_banks)) do
    banks = Bank.available_in_city(user.city.code)
    reply = Enum.join(banks, "\n")

    Nadia.send_message(chat_id, reply, reply_markup: fav_banks_kbd(user.language))
  end

  defp handle_private_message(user, chat_id, text) when text in unquote(values(@add_bank)) do
    reply = I18n.t!(user.language, "banks.select")

    Nadia.send_message(chat_id, reply, reply_markup: banks_to_add_kbd(user))
  end

  defp handle_private_message(user, chat_id, text) when text in unquote(values(@rm_bank)) do
    reply = I18n.t!(user.language, "banks.select")

    Nadia.send_message(chat_id, reply, reply_markup: banks_to_remove_kbd(user))
  end

  defp handle_private_message(user, chat_id, text) when text in unquote(values(@rm_fav_banks)) do
    user_change = Ecto.Changeset.change(user, fav_banks: [])
    Repo.update(user_change)

    user = User.find_or_create_by_chat_id(chat_id)
    handle_private_message(user, chat_id, translate(user.language, @fav_banks))
  end

  defp handle_private_message(user, chat_id, "⭐️" <> bank) do
    user_change = Ecto.Changeset.change(user, fav_banks: user.fav_banks ++ [String.trim(bank)])
    Repo.update(user_change)

    user = User.find_or_create_by_chat_id(chat_id)
    handle_private_message(user, chat_id, translate(user.language, @fav_banks))
  end

  defp handle_private_message(user, chat_id, "❌ " <> bank) do
    user_change = Ecto.Changeset.change user, fav_banks: user.fav_banks -- [bank]
    Repo.update user_change

    user = User.find_or_create_by_chat_id(chat_id)
    handle_private_message(user, chat_id, translate(user.language, @fav_banks))
  end

  #
  # Manage current city
  #
  defp handle_private_message(user, chat_id, text) when text in unquote(values(@edit_city)) do
    city = user.city.name
    reply = I18n.t!(user.language, "city.current", city: city)

    Nadia.send_message(chat_id, reply, parse_mode: "Markdown", reply_markup: detect_city_kbd(user.language))
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
          I18n.t!(user.language, "city.current", city: city_name)
        nil ->
          I18n.t!(user.language, "city.not_support")
      end

    Nadia.send_message(chat_id, reply, parse_mode: "Markdown", reply_markup: default_kbd(user.language))
  end

  defp handle_private_message(user, chat_id, text) when text in unquote(values(@city_manual)) do
    city = user.city.name
    reply = """
    #{I18n.t!(user.language, "city.current", city: city)}

    #{I18n.t!(user.language, "city.edit")}
    `/city Санкт-Петербург`
    """

    Nadia.send_message(chat_id, reply, parse_mode: "Markdown", reply_markup: detect_city_kbd(user.language))
  end

  #
  # Change language
  #
  defp handle_private_message(user, chat_id, "/lang " <> lang) when lang in ["ru", "en"] do
    changeset = User.changeset(user, %{language: lang})
    Repo.update!(changeset)

    reply = I18n.t!(lang, "select_currency")

    Nadia.send_message(chat_id, reply, reply_markup: default_kbd(lang))
  end

  defp handle_private_message(user, chat_id, unquote(@lang.ru)) do
    handle_private_message(user, chat_id, "/lang en")
  end

  defp handle_private_message(user, chat_id, unquote(@lang.en)) do
    handle_private_message(user, chat_id, "/lang ru")
  end

  # Default fallback function
  defp handle_private_message(user, chat_id, _) do
    reply = I18n.t!(user.language, "select_currency")

    Nadia.send_message(chat_id, reply, reply_markup: default_kbd(user.language))
  end

  #
  # Custom Keyboards
  #
  #
  # Default keyboard
  defp default_kbd(lang) do
    %ReplyKeyboardMarkup{keyboard: [
                          [translate(lang, @usd)],
                          [translate(lang, @eur)],
                          [translate(lang, @cb)],
                          [translate(lang, @settings)],
                          [translate(lang, @about)]
                         ],
                         resize_keyboard: true,
                         one_time_keyboard: true}
  end

  # Settings keyboard
  defp settings_kbd(lang) do
    %ReplyKeyboardMarkup{keyboard: [
                          [translate(lang, @edit_city)],
                          [translate(lang, @fav_banks)],
                          [translate(lang, @lang)],
                          [translate(lang, @main_menu)]
                         ],
                         resize_keyboard: true,
                         one_time_keyboard: true}
  end

  # Fav banks keyboard
  defp fav_banks_kbd(lang) do
    %ReplyKeyboardMarkup{keyboard: [
                          [translate(lang, @all_banks)],
                          [translate(lang, @add_bank)],
                          [translate(lang, @rm_bank)],
                          [translate(lang, @rm_fav_banks)],
                          [translate(lang, @main_menu)]
                         ],
                         resize_keyboard: true,
                         one_time_keyboard: true}
  end

  defp banks_to_add_kbd(user) do
    banks = Bank.available_in_city(user.city.code) -- user.fav_banks
    banks_cmds = Enum.map(banks, fn(x) -> ["⭐️ " <> x] end)
    buttons = [[translate(user.language, @main_menu)]] ++ banks_cmds

    # TODO: Replace that hack with anything less hacky
    buttons = Enum.take(buttons, 135)

    %ReplyKeyboardMarkup{keyboard: buttons,
                         resize_keyboard: true,
                         one_time_keyboard: true}
  end

  defp banks_to_remove_kbd(user) do
    banks = Enum.map(user.fav_banks, fn(x) -> ["❌ " <> x] end)
    buttons = [[translate(user.language, @main_menu)]] ++ banks
    %ReplyKeyboardMarkup{keyboard: buttons,
                         resize_keyboard: true,
                         one_time_keyboard: true}
  end

  # Current city keyboard
  defp detect_city_kbd(lang) do
    %ReplyKeyboardMarkup{
      keyboard: [
        [translate(lang, @city_manual)],
        [%Nadia.Model.KeyboardButton{text: translate(lang, @city_auto), request_location: true}],
        [translate(lang, @main_menu)]
      ],
      resize_keyboard: true,
      one_time_keyboard: true
    }
  end
end
