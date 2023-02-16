defmodule Jumubase.Repo.Migrations.AddCoordinatesToStages do
  use Ecto.Migration

  def change do
    alter table(:stages) do
      add :latitude, :float
      add :longitude, :float
    end
  end
end
