defmodule Jumubase.Accounts.User do
  use Jumubase.Schema
  import Ecto.Changeset
  import Jumubase.Gettext
  alias Jumubase.JumuParams
  alias Jumubase.Utils
  alias Jumubase.Accounts.User
  alias Jumubase.Foundation.Host

  schema "users" do
    field :given_name, :string
    field :family_name, :string
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :role, :string

    many_to_many :hosts, Host, join_through: "hosts_users", on_replace: :delete

    timestamps()
  end

  @base_attrs [:given_name, :family_name, :email, :role]

  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @base_attrs)
    |> validate_required(@base_attrs)
    |> validate_inclusion(:role, JumuParams.user_roles())
    |> validate_format(:email, Utils.email_format())
    |> unique_email()
  end

  @doc """
  A user changeset for creating a new user.
  """
  def create_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @base_attrs ++ [:password])
    |> validate_required(@base_attrs)
    |> validate_inclusion(:role, JumuParams.user_roles())
    |> validate_format(:email, Utils.email_format())
    |> unique_email()
    |> validate_password(hash_password: true)
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: dgettext("errors", "does not match password"))
    |> validate_password(opts)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  # Private helpers

  defp unique_email(changeset) do
    validate_format(changeset, :email, ~r/^[^\s]+@[^\s]+$/)
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, Jumubase.Repo)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required(:password)
    |> validate_length(:password, min: 8, max: 72)
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> validate_length(:password, max: 72, count: :bytes)
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end
end
