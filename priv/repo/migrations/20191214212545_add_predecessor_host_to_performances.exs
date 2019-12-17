defmodule Jumubase.Repo.Migrations.AddPredecessorHostToPerformances do
  use Ecto.Migration
  import Ecto.Query
  alias Jumubase.Repo

  def up do
    alter table(:performances) do
      add :predecessor_host_id, references(:hosts, on_delete: :nilify_all)
    end

    flush()

    from(c in "contests",
      join: h in "hosts",
      on: c.host_id == h.id,
      select: %{contest_id: c.id, host_id: h.id}
    )
    |> Repo.all()
    |> Enum.each(fn row ->
      Repo.update_all(
        from(p in "performances", where: p.predecessor_contest_id == ^row.contest_id),
        set: [predecessor_host_id: row.host_id]
      )
    end)

    create index(:performances, :predecessor_host_id)
  end

  def down do
    alter table(:performances) do
      remove :predecessor_host_id
    end
  end
end
