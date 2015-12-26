defmodule Currexbot.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table :users do
      add :chat_id, :integer
      add :city, :string
      add :fav_banks, {:array, :string}
      add :default_sort, :string
      add :language, :string

      timestamps
    end

    create unique_index(:users, [:chat_id])
  end
end
