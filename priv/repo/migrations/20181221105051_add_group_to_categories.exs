defmodule Jumubase.Repo.Migrations.AddGroupToCategories do
  use Ecto.Migration

  def change do
    alter table(:categories) do
      add :group, :string
    end
  end
end
