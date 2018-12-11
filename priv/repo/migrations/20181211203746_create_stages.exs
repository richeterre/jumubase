defmodule Jumubase.Repo.Migrations.CreateStages do
  use Ecto.Migration

  def change do
    create table(:stages) do
      add :name, :string
      add :host_id, references(:hosts, on_delete: :delete_all)

      timestamps()
    end

    create index(:stages, [:host_id])
  end
end
