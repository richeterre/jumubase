defmodule Jumubase.Repo.Migrations.CreateContests do
  use Ecto.Migration

  def change do
    create table(:contests) do
      add :host_id, references(:hosts, on_delete: :delete_all), null: false
      add :season, :integer
      add :round, :integer
      add :start_date, :date
      add :end_date, :date
      add :signup_deadline, :date

      timestamps()
    end

    create index(:contests, [:host_id])
  end
end
