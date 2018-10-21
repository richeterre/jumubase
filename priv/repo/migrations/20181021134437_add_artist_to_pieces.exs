defmodule Jumubase.Repo.Migrations.AddArtistToPieces do
  use Ecto.Migration

  def change do
    alter table(:pieces) do
      add :artist, :string
    end
    rename table(:pieces), :composer_name, to: :composer
  end
end
