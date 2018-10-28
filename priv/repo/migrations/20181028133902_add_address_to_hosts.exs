defmodule Jumubase.Repo.Migrations.AddAddressToHosts do
  use Ecto.Migration

  def change do
    alter table(:hosts) do
      add :address, :text
    end
  end
end
