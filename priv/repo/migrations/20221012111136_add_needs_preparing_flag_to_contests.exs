defmodule Jumubase.Repo.Migrations.AddNeedsPreparingFlagToContests do
  use Ecto.Migration

  def change do
    alter table(:contests) do
      add :needs_preparing, :boolean, null: false, default: false
    end
  end
end
