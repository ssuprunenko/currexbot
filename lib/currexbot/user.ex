defmodule Currexbot.User do
  use Ecto.Schema
  alias Currexbot.Repo
  alias Currexbot.User
  alias Currexbot.City
  import Ecto.Changeset

  schema "users" do
    field :chat_id, :integer
    field :fav_banks, {:array, :string}
    field :default_sort, :string
    field :language, :string

    belongs_to :city, Currexbot.City, defaults: [name: "Москва"]

    timestamps
  end

  @required_fields ~w(chat_id city_id)
  @optional_fields ~w(fav_banks default_sort language)

  def changeset(user, params \\ :empty) do
    user
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:chat_id)
  end

  def find_or_create_by_chat_id(chat_id) when is_integer(chat_id) do
    case (user = Repo.get_by(User, chat_id: chat_id)) do
      %User{} ->
        user |> Repo.preload(:city)
      nil ->
        default_city = Repo.get_by(City, name: "Москва")
        %User{chat_id: chat_id, city_id: default_city.id}
        |> Repo.insert!
        |> Repo.preload(:city)
    end
  end
end
