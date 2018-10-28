defmodule Jumubase.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Jumubase.Gettext
  alias Jumubase.JumuParams
  alias Jumubase.Utils
  alias Jumubase.Accounts.User
  alias Jumubase.Foundation.Host

  schema "users" do
    field :given_name, :string
    field :family_name, :string
    field :role, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :confirmed_at, :utc_datetime
    field :reset_sent_at, :utc_datetime
    field :sessions, {:map, :integer}, default: %{}

    many_to_many :hosts, Host, join_through: "hosts_users", on_replace: :delete

    timestamps()
  end

  @base_attrs [:given_name, :family_name, :email, :role]

  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @base_attrs)
    |> validate_required(@base_attrs)
    |> validate_format(:email, Utils.email_format)
    |> validate_inclusion(:role, JumuParams.user_roles())
    |> unique_email
  end

  def create_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @base_attrs ++ [:password])
    |> validate_required(@base_attrs)
    |> validate_required(:password)
    |> validate_inclusion(:role, JumuParams.user_roles())
    |> unique_email
    |> validate_password(:password)
    |> put_pass_hash
  end

  defp unique_email(changeset) do
    validate_format(changeset, :email, ~r/@/)
    |> validate_length(:email, max: 254)
    |> unique_constraint(:email)
  end

  # Also check out NotQwerty123.PasswordStrength.strong_password?
  defp validate_password(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, password ->
      case strong_password?(password) do
        {:ok, _} -> []
        {:error, msg} -> [{field, options[:message] || msg}]
      end
    end)
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes:
      %{password: password}} = changeset) do
    change(changeset, Comeonin.Bcrypt.add_hash(password))
  end
  defp put_pass_hash(changeset), do: changeset

  defp strong_password?(password) when byte_size(password) > 7 do
    {:ok, password}
  end
  defp strong_password?(_), do: {:error, dgettext("errors", "The password is too short.")}
end
