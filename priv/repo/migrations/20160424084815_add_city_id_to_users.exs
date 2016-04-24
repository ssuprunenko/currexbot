defmodule Currexbot.Repo.Migrations.AddCityIdToUsers do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :city_id, references(:cities)
    end
    create index(:users, [:city_id])
  end

  def down do
    alter table(:users) do
      remove :city_id
    end
  end
end
