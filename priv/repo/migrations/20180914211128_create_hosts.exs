defmodule Jumubase.Repo.Migrations.CreateHosts do
  use Ecto.Migration

  def change do
    create table(:hosts) do
      add :name, :string
      add :city, :string
      add :country_code, :string
      add :time_zone, :string

      timestamps()
    end
  end
end
