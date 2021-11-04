defmodule Jumubase.Repo.Migrations.ReplacePhauxthFieldsByPhxAuth do
  use Ecto.Migration

  def change do
    rename table(:users), :password_hash, to: :hashed_password

    alter table(:users) do
      remove :confirmed_at, :utc_datetime
      remove :reset_sent_at, :utc_datetime
      remove :sessions, {:map, :integer}, default: "{}"
    end

    create table(:users_tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])
  end
end
