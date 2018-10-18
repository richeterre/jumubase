defmodule Jumubase.Repo.Migrations.CreateAppearances do
  use Ecto.Migration

  def change do
    create table(:appearances) do
      add :performance_id, references(:performances, on_delete: :delete_all), null: false
      add :participant_id, references(:participants, on_delete: :delete_all), null: false
      add :participant_role, :string
      add :instrument, :string
      add :points, :integer

      timestamps()
    end

    create unique_index(:appearances,
      [:performance_id, :participant_id],
      name: :no_multiple_appearances
    )
    create index(:appearances, [:participant_id])
  end
end
