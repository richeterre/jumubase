defmodule Jumubase.Repo.Migrations.CreatePieces do
  use Ecto.Migration

  def change do
    create table(:pieces) do
      add :performance_id, references(:performances, on_delete: :delete_all), null: false
      add :title, :string
      add :composer_name, :string
      add :composer_born, :string
      add :composer_died, :string
      add :epoch, :string
      add :minutes, :integer
      add :seconds, :integer

      timestamps()
    end

    create index(:pieces, [:performance_id])
  end
end
