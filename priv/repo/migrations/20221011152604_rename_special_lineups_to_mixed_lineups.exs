defmodule Jumubase.Repo.Migrations.RenameSpecialLineupsToMixedLineups do
  use Ecto.Migration
  import Ecto.Query

  def change do
    Jumubase.Foundation.Category
    |> where(group: "special_lineups")
    |> Jumubase.Repo.update_all(set: [group: "mixed_lineups"])
  end
end
