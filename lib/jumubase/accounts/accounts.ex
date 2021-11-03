defmodule Jumubase.Accounts do
  @moduledoc """
  The boundary for the Accounts system.
  """

  import Ecto.Query
  alias Jumubase.Repo
  alias Jumubase.Foundation
  alias Jumubase.Accounts.{User, UserToken, UserNotifier}

  @doc """
  Returns all users.
  """
  def list_users do
    User |> order_by(:given_name) |> Repo.all()
  end

  @doc """
  Gets a user by email.
  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by email and password. Returns nil if the password is incorrect.
  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.
  """
  def get_user!(id), do: Repo.get!(User, id)

  def create_user(attrs) do
    %User{hosts: []}
    |> User.create_changeset(attrs)
    |> put_hosts_assoc(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    # Preloading is needed for putting new hosts
    |> Repo.preload(:hosts)
    |> User.changeset(attrs)
    |> put_hosts_assoc(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns a changeset for editing the user.
  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Returns a changeset for changing the user password.
  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_session_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "session"))
    :ok
  end

  ## Reset password

  @doc """
  Delivers the reset password email to the given user.
  """
  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the user by reset password token.
  """
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Resets the user password.
  """
  def reset_user_password(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## Preloading

  @doc """
  Loads associated hosts into the given users.
  """
  def load_hosts(users) do
    Repo.preload(users, :hosts)
  end

  # Private helpers

  # Looks up the given host ids and associates the hosts with the user.
  defp put_hosts_assoc(changeset, user_params) do
    host_ids = user_params[:host_ids] || user_params["host_ids"] || []
    hosts = Foundation.list_hosts(host_ids)
    Ecto.Changeset.put_assoc(changeset, :hosts, hosts)
  end
end
