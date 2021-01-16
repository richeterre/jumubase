defmodule Jumubase.Repo.Migrations.AddAllowsWespeNominationsFlagToContestCategories do
  use Ecto.Migration

  def change do
    alter table(:contest_categories) do
      add :allows_wespe_nominations, :boolean, null: false, default: false
    end
  end
end
