defmodule Currexbot.Repo.Migrations.CreateCities do
  use Ecto.Migration

  def change do
    create table :cities do
      add :name, :string
      add :code, :integer
    end
  end
end
