defmodule Jumubase.Auth.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jumubase.JumuParams
  alias Jumubase.Auth.User

  schema "users" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:password_hash, :string)
    field(:role, :string)

    timestamps()
  end

  @required_attrs [:first_name, :last_name, :email, :role]

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> validate_inclusion(:role, JumuParams.roles())
    |> unique_constraint(:email)
  end
end
