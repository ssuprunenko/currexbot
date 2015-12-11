defmodule Currexbot.Currency do
  import SweetXml

  @file_path "test/fixtures/spb.xml"

  def get_rates(currency, sort_el) do
    {:ok, doc} = File.read(@file_path)

    doc
    |> parse_xml(currency)
    |> sort_by(sort_el)
    |> prettify
  end

  defp parse_xml(doc, currency) do
    xpath(doc, ~x"//Actual_Rates/Bank"l,
      name: ~x"./Name/text()"s,
      value: ~x"./#{currency}/Buy/text()"s
    )
  end

  defp sort_by(rates, sort_el) do
    if sort_el == "name" do
      Enum.sort_by rates, fn(bank) -> bank.name end
    else
      Enum.sort_by rates, fn(bank) -> bank.value end, &>=/2
    end
  end

  defp prettify(rates) do
    rates
    |> Enum.map(fn(bank) -> "#{bank.name}: #{bank.value}" end)
    |> Enum.join("\n")
  end
end
