defmodule Currexbot.Repo.Migrations.AddCityIdToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :city_id, references(:cities)
      remove :city
    end
    create index(:users, [:city_id])
  end
end
