defmodule Currexbot.Repo.Migrations.CreateCities do
  use Ecto.Migration

  def change do
    create table :cities do
      add :name, :string
      add :code, :string
    end
  end
end
