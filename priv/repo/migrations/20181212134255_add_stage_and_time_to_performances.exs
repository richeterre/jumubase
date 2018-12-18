defmodule Jumubase.Repo.Migrations.AddStageAndTimeToPerformances do
  use Ecto.Migration

  def change do
    alter table(:performances) do
      add :stage_id, references(:stages, on_delete: :nilify_all)
      add :stage_time, :naive_datetime
    end

    create index(:performances, [:stage_id])
  end
end
