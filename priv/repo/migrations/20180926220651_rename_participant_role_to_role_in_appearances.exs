defmodule Jumubase.Repo.Migrations.RenameParticipantRoleToRoleInAppearances do
  use Ecto.Migration

  def change do
    rename table(:appearances), :participant_role, to: :role
  end
end
