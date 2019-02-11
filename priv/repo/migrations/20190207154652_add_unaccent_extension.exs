defmodule Jumubase.Repo.Migrations.AddUnaccentExtension do
  use Ecto.Migration

  def up do
    execute "CREATE extension if not exists unaccent;"
  end

  def down do
    execute "DROP extension if exists unaccent;"
  end
end
