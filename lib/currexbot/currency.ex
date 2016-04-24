defmodule Currexbot.Currency do
  @moduledoc """
  Fetches XML data from kovalut.ru with actual exchange rates.
  Parses it, filters by favorite banks' list and formats results.
  """
  import SweetXml

  @base_url "http://informer.kovalut.ru/webmaster/xml-table.php?kod="

  def get_rates(user, currency \\ "USD", sort_el \\ "name") do
    user.city.code
    |> fetch_xml
    |> parse_xml(currency)
    |> filter_banks(user.fav_banks)
    |> sort_rates(sort_el)
    |> prettify
  end

  defp fetch_xml(city_code) do
    url = @base_url <> to_string(city_code)
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
    case Enum.count(fav_banks) do
      0 -> rates
      _ -> Enum.filter(rates, fn(bank) -> String.contains?(bank.name, fav_banks) end)
    end
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
