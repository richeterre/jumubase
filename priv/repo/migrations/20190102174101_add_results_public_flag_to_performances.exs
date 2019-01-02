defmodule Jumubase.Repo.Migrations.AddResultsPublicFlagToPerformances do
  use Ecto.Migration

  def change do
    alter table(:performances) do
      add :results_public, :boolean, null: false, default: false
    end
  end
end
