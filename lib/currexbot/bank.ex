defmodule Currexbot.Bank do
  @base_url "http://kovalut.ru/bankslist.php?kod="

  def available_in_city(city_code \\ "7801") do
    city_code
    |> fetch_html
    |> Floki.find(".tbn a")
    |> Enum.map(fn(x) -> x |> Floki.text |> String.strip end)
  end

  defp fetch_html(city_code) do
    url = @base_url <> city_code
    %HTTPoison.Response{status_code: 200, body: body} = HTTPoison.get! url
    body
  end
end
