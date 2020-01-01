defmodule Jumubase.Repo.Migrations.AddAllowsRegistrationFlagToContests do
  use Ecto.Migration

  def change do
    alter table(:contests) do
      add :allows_registration, :boolean, null: false, default: true
    end
  end
end
