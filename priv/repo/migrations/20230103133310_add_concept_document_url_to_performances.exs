defmodule Jumubase.Repo.Migrations.AddConceptDocumentUrlToPerformances do
  use Ecto.Migration

  def change do
    alter table(:performances) do
      add :concept_document_url, :string
    end
  end
end
