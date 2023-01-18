defmodule Jumubase.Repo.Migrations.AddRequiresConceptDocumentToContestCategories do
  use Ecto.Migration

  def change do
    alter table(:contest_categories) do
      add :requires_concept_document, :boolean, null: false, default: false
    end
  end
end
