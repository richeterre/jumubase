defmodule Jumubase.Repo.Migrations.AddRequiresConceptDocumentToCategories do
  use Ecto.Migration

  def change do
    alter table(:categories) do
      add :requires_concept_document, :boolean, null: false, default: false
    end
  end
end
