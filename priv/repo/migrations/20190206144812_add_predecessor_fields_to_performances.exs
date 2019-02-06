defmodule Jumubase.Repo.Migrations.AddPredecessorFieldsToPerformances do
  use Ecto.Migration

  def change do
    alter table(:performances) do
      add :predecessor_id, references(:performances, on_delete: :nilify_all)
      add :predecessor_contest_id, references(:contests, on_delete: :nilify_all)
    end

    create index(:performances, :predecessor_id)
    create index(:performances, :predecessor_contest_id)
  end
end
