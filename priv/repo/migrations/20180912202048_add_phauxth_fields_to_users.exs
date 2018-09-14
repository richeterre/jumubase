defmodule Jumubase.Repo.Migrations.AddPhauxthFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :confirmed_at, :utc_datetime
      add :reset_sent_at, :utc_datetime
      add :sessions, {:map, :integer}, default: "{}"
    end
  end
end
