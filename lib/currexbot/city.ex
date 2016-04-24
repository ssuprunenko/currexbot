defmodule Currexbot.City do
  use Ecto.Schema

  schema "cities" do
    field :name, :string
    field :code, :integer
  end
end
