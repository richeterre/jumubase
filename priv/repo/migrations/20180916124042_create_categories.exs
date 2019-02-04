defmodule Jumubase.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string
      add :short_name, :string
      add :genre, :string
      add :type, :string

      timestamps()
    end
  end
end
