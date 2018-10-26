defmodule Jumubase.Repo.Migrations.AddCoordinatesToHosts do
  use Ecto.Migration

  def change do
    alter table(:hosts) do
      add :latitude, :float
      add :longitude, :float
    end
  end
end
