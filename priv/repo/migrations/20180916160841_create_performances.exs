defmodule Jumubase.Repo.Migrations.CreatePerformances do
  use Ecto.Migration

  def change do
    create table(:performances) do
      add :contest_category_id, references(:contest_categories, on_delete: :delete_all), null: false
      add :edit_code, :string
      add :age_group, :string

      timestamps()
    end

    create unique_index(:performances, [:edit_code])
    create index(:performances, [:contest_category_id])
    create index(:performances, [:age_group])
  end
end
