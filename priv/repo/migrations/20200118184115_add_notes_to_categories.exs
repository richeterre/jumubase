defmodule Jumubase.Repo.Migrations.AddNotesToCategories do
  use Ecto.Migration

  def change do
    alter table(:categories) do
      add :notes, :string
    end
  end
end
