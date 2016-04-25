defmodule Currexbot.City do
  use Ecto.Schema
  alias Currexbot.Repo
  alias Currexbot.City

  @base_url "https://geocode-maps.yandex.ru/1.x/?results=1&kind=locality&sco=latlong&geocode="

  schema "cities" do
    field :name, :string
    field :code, :string
  end

  def geocode(lat, long) do
    fetch_xml(lat, long)
    |> Floki.find("name")
    |> Floki.text
    |> find_by_name
  end

  def find_by_name(name) do
    case (city = Repo.get_by(City, name: name)) do
      %City{} ->
        {:ok, city}
      nil ->
        {:error, "City not found"}
    end
  end

  defp fetch_xml(lat, long) do
    url = @base_url <> "#{lat},#{long}"
    %HTTPoison.Response{status_code: 200, body: body} = HTTPoison.get! url
    body
  end
end
