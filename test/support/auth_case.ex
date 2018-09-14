defmodule JumubaseWeb.AuthCase do
  use Phoenix.ConnTest

  import Ecto.Changeset
  alias Jumubase.Factory
  alias Jumubase.{Accounts, Repo}

  def add_user(attrs \\ []) do
    # Add password since Factory doesn't set one
    attrs = attrs |> Keyword.put_new(:password, "reallyHard2gue$$")

    user = Factory.params_for(:user, attrs)
    {:ok, user} = Accounts.create_user(user)
    user
  end

  def add_reset_user(email) do
    add_user(email: email)
    |> change(%{confirmed_at: DateTime.utc_now()})
    |> change(%{reset_sent_at: DateTime.utc_now()})
    |> Repo.update!()
  end

  def add_phauxth_session(conn, user) do
    session_id = Phauxth.Login.gen_session_id("F")
    Accounts.add_session(user, session_id, System.system_time(:second))
    Phauxth.Login.add_session(conn, session_id, user.id)
  end

  def gen_key(email) do
    Phauxth.Token.sign(JumubaseWeb.Endpoint, %{"email" => email})
  end
end
