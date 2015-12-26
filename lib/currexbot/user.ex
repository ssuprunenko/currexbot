defmodule Currexbot.User do
  use Ecto.Schema
  alias Currexbot.Repo
  alias Currexbot.User

  schema "users" do
    field :chat_id, :integer
    field :city, :string
    field :fav_banks, {:array, :string}
    field :default_sort, :string
    field :language, :string

    timestamps
  end

  def find_or_create_by_chat_id(chat_id) when is_integer(chat_id) do
    case (user = Repo.get_by(User, chat_id: chat_id)) do
      %User{} -> user
      nil -> Repo.insert!(%User{chat_id: chat_id})
    end
  end
end
