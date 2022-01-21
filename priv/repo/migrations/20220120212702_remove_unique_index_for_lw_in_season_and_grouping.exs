defmodule Jumubase.Repo.Migrations.RemoveUniqueIndexForLWInSeasonAndGrouping do
  use Ecto.Migration

  def change do
    drop index(:contests, [:season, :grouping], name: :one_lw_per_season_and_grouping)
  end
end
