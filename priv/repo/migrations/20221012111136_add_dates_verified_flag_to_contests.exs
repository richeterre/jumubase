defmodule Jumubase.Repo.Migrations.AddDatesVerifiedFlagToContests do
  use Ecto.Migration

  def change do
    alter table(:contests) do
      add :dates_verified, :boolean, null: false, default: true
    end
  end
end
