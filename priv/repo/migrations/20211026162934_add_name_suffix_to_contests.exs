defmodule Jumubase.Repo.Migrations.AddNameSuffixToContests do
  use Ecto.Migration

  def change do
    alter table(:contests) do
      add :name_suffix, :string
    end
  end
end
