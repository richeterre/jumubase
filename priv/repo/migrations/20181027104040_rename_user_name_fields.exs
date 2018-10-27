defmodule Jumubase.Repo.Migrations.RenameUserNameFields do
  use Ecto.Migration

  def change do
    rename table(:users), :first_name, to: :given_name
    rename table(:users), :last_name, to: :family_name
  end
end
