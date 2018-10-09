defmodule Jumubase.Repo.Migrations.AddAgeGroupToAppearances do
  use Ecto.Migration

  def change do
    alter table(:appearances) do
      add :age_group, :string
    end
  end
end
