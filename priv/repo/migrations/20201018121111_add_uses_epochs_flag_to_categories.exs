defmodule Jumubase.Repo.Migrations.AddUsesEpochsFlagToCategories do
  use Ecto.Migration

  def change do
    alter table(:categories) do
      add :uses_epochs, :boolean, null: false, default: true
    end
  end
end
