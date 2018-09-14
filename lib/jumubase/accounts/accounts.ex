defmodule Jumubase.Accounts do
  @moduledoc """
  The boundary for the Accounts system.
  """

  import Ecto.Changeset
  alias Jumubase.{Accounts.User, Repo}

  def list_users do
    Repo.all(User)
  end

  def get(id), do: Repo.get(User, id)

  def get!(id), do: Repo.get!(User, id)

  def get_by(%{"email" => email}) do
    Repo.get_by(User, email: email)
  end

  def create_user(attrs) do
    %User{}
    |> User.create_changeset(attrs)
    |> change(confirmed_at: DateTime.utc_now()) # Auto-confirm
    |> Repo.insert()
  end

  def create_password_reset(endpoint, attrs) do
    with %User{} = user <- get_by(attrs) do
      change(user, %{reset_sent_at: DateTime.utc_now}) |> Repo.update
      Phauxth.Token.sign(endpoint, attrs)
    end
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def update_password(%User{} = user, attrs) do
    user
    |> User.create_changeset(attrs)
    |> change(%{reset_sent_at: nil, sessions: %{}})
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def list_sessions(user_id) do
    with user when is_map(user) <- Repo.get(User, user_id), do: user.sessions
  end

  def add_session(%User{sessions: sessions} = user, session_id, timestamp) do
    change(user, sessions: put_in(sessions, [session_id], timestamp))
    |> Repo.update
  end

  def delete_session(%User{sessions: sessions} = user, session_id) do
    change(user, sessions: Map.delete(sessions, session_id))
    |> Repo.update
  end

  def remove_old_sessions(session_age) do
    now = System.system_time(:second)
    Enum.map(
      list_users(),
      &(change(
          &1,
          sessions:
            :maps.filter(
              fn _, time ->
                time + session_age > now
              end,
              &1.sessions
            )
        )
        |> Repo.update())
    )
  end
end
