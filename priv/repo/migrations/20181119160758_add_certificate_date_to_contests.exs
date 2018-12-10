defmodule Jumubase.Repo.Migrations.AddCertificateDateToContests do
  use Ecto.Migration

  def change do
    alter table(:contests) do
      add :certificate_date, :date
    end
  end
end
