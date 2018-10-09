defmodule Jumubase.Repo.Migrations.RenameSignupDeadlineToDeadlineInContests do
  use Ecto.Migration

  def change do
    rename table(:contests), :signup_deadline, to: :deadline
  end
end
