defmodule Jumubase.Repo.Migrations.AddGroupsAccompanistsFlagToContestCategories do
  use Ecto.Migration

  def change do
    alter table(:contest_categories) do
      add :groups_accompanists, :boolean, null: false, default: false
    end
  end
end
