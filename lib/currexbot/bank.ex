defmodule Currexbot.Bank do
  @base_url "http://kovalut.ru/bankslist.php?kod="

  def available_in_city(city_code) do
    city_code
    |> fetch_html
    |> Floki.find(".tbn a")
    |> Enum.map(fn(x) -> x |> Floki.text |> String.strip end)
  end

  defp fetch_html(city_code) do
    url = @base_url <> to_string(city_code)
    %HTTPoison.Response{body: body} = HTTPoison.get! url
    body
  end
end
