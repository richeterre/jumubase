defmodule Jumubase.Repo.Migrations.AddUniqueIndexForLWInSeasonAndGrouping do
  use Ecto.Migration

  def change do
    create unique_index(:contests, [:season, :grouping],
             where: "round = 2",
             name: :one_lw_per_season_and_grouping
           )
  end
end
