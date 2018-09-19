defmodule Jumubase.Repo.Migrations.CreateParticipants do
  use Ecto.Migration

  def change do
    create table(:participants) do
      add :given_name, :string
      add :family_name, :string
      add :birthdate, :date
      add :phone, :string
      add :email, :string

      timestamps()
    end
  end
end
