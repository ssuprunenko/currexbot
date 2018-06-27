defmodule Currexbot.Bank do
  @base_url "https://kovalut.ru/bankslist.php?kod="

  def available_in_city(city_code) do
    city_code
    |> fetch_html
    |> Floki.find(".tbn a")
    |> Enum.map(fn(x) -> x |> Floki.text |> String.strip end)
  end

  defp fetch_html(city_code) do
    url = @base_url <> to_string(city_code)
    %HTTPoison.Response{status_code: 200, body: body} = HTTPoison.get!(url, [], [follow_redirect: true])
    body
  end
end
