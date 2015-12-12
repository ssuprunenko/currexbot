defmodule Currexbot.Currency do
  @moduledoc """
  Fetches XML data from kovalut.ru with actual exchange rates.
  Parses it, filters by favorite banks' list and formats results.
  """
  import SweetXml

  @base_url "http://informer.kovalut.ru/webmaster/xml-table.php?kod="
  @fav_banks ["Балтийский Банк", "Банк «ФК Открытие»", "ВТБ 24",
              "Сбербанк России", "Банк «Советский»", "Райффайзенбанк"]

  def get_rates(currency \\ "USD", sort_el \\ "name", city_code \\ "7801") do
    city_code
    |> fetch_xml
    |> parse_xml(currency)
    |> filter_banks(@fav_banks)
    |> sort_rates(sort_el)
    |> prettify
  end

  defp fetch_xml(city_code) do
    url = @base_url <> city_code
    %HTTPoison.Response{status_code: 200, body: body} = HTTPoison.get! url
    body
  end

  defp parse_xml(doc, currency) do
    xpath(doc, ~x"//Bank"l,
      name: ~x"./Name/text()"s,
      buy: ~x"./#{currency}/Buy/text()"s,
      sell: ~x"./#{currency}/Sell/text()"s
    )
  end

  defp filter_banks(rates, fav_banks) do
    Enum.filter(rates, fn(bank) -> String.contains?(bank.name, fav_banks) end)
  end

  defp sort_rates(rates, sort_el) do
    if sort_el == "name" do
      Enum.sort_by rates, fn(bank) -> bank.name end
    else
      Enum.sort_by rates, fn(bank) -> bank.buy end, &>=/2
    end
  end

  defp prettify(rates) do
    rates
    |> Enum.map(fn(bank) -> "#{bank.name}: #{bank.buy} • #{bank.sell}" end)
    |> Enum.join("\n")
  end
end
