defmodule Jumubase.Repo.Migrations.AddTimetablesPublicFlagToContests do
  use Ecto.Migration

  def change do
    alter table(:contests) do
      add :timetables_public, :boolean, null: false, default: false
    end
  end
end
