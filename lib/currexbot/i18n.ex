defmodule I18n do
  @moduledoc """
  i18n module
  """
  use Linguist.Vocabulary

  locale "en", [
    select_currency: "Select currency:",
    cb: [
      usd: "USD %{rates}",
      eur: "Euro %{rates}"
    ],
    city: [
      current: "Your current city — *%{city}*",
      not_support: "Sorry, your city is not supported yet. Bot works only with Russian cities.",
      edit: "To change your city:"
    ],
    banks: [
      no_fav: "You don't have any favorite banks",
      your_fav: "Your favorite banks:\n",
      select: "Select bank:"
    ],
    settings: [
      current: "Your current settings:",
      city: "City: %{city}",
      lang: "Language: English"
    ],
    about_msg: """
    This bot shows actual exchange rates for USD and Euro in banks of your city along with rates in Central Bank of Russia.
    Only Russian cities are supported now.

    You can change your city and favorite banks in /settings. Bot uses all banks in Moscow by default.
    Service powered by http://kovalut.ru

    Use /usd or /eur to check actual exchange rates.

    If you have some questions hesitate to contact me suprunenko.s@gmail.com
    I hope this bot will be useful for you.

    _Введите_ "/lang ru", _чтобы изменить язык на русский._
    """
  ]

  locale "ru", [
    select_currency: "Выберите валюту:",
    cb: [
      usd: "Доллар %{rates}",
      eur: "Евро %{rates}"
    ],
    city: [
      current: "Ваш текущий город — *%{city}*",
      not_support: "Извините, ваш город пока не поддерживается",
      edit: "Команда для изменения города:"
    ],
    banks: [
      no_fav: "У вас нет избранных банков",
      your_fav: "Ваши избранные банки:\n",
      select: "Выберите банк:"
    ],
    settings: [
      current: "Ваши текущие настройки:",
      city: "Город: %{city}",
      lang: "Язык: Русский"
    ],
    about_msg: """
    Бот показывает актуальные курсы доллара и евро в банках вашего города, а также курсы валют ЦБ на сегодняшний день.
    В настройках вы можете выбрать ваш текущий город и добавить банки в избранное. По умолчанию показываются курсы всех банков Москвы.
    Провайдер данных — сервис http://kovalut.ru
    На данный момент поддерживаются только российские банки.

    Используйте команды /usd и /eur, чтобы посмотреть курсы доллара и евро на текущий момент.

    По любым вопросам, связанным с работой бота, пишите на адрес suprunenko.s@gmail.com
    Надеюсь, этот бот будет вам полезен.

    _Use_ "/lang en" _to switch bot language to English._
    """
  ]
end
