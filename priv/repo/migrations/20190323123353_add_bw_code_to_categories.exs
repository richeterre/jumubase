defmodule Jumubase.Repo.Migrations.AddBWCodeToCategories do
  use Ecto.Migration

  def change do
    alter table(:categories) do
      add :bw_code, :string
    end
  end
end
