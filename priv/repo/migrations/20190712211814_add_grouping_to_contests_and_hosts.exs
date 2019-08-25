defmodule Jumubase.Repo.Migrations.AddGroupingToContestsAndHosts do
  use Ecto.Migration

  # By default, use the grouping that "existed" before multi-grouping support
  @default_grouping "2"

  def change do
    alter table(:contests) do
      add :grouping, :string, null: false, default: @default_grouping
    end

    alter table(:hosts) do
      add :current_grouping, :string, null: false, default: @default_grouping
    end
  end
end
