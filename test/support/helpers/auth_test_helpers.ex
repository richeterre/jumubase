defmodule JumubaseWeb.AuthTestHelpers do
  import Phoenix.ConnTest
  import ExUnit.Assertions
  import Ecto.Changeset
  import Jumubase.Factory
  alias Jumubase.Repo
  alias Jumubase.Accounts
  alias JumubaseWeb.Router.Helpers, as: Routes

  def add_user(attrs \\ []) do
    # Add password since Factory doesn't set one
    attrs = attrs |> Keyword.put_new(:password, "reallyHard2gue$$")

    user = params_for(:user, attrs)
    {:ok, user} = Accounts.create_user(user)
    user
  end

  def add_reset_user(email) do
    add_user(email: email)
    |> change(%{confirmed_at: DateTime.utc_now()})
    |> change(%{reset_sent_at: DateTime.utc_now()})
    |> Repo.update!()
  end

  def gen_key(email) do
    Phauxth.Token.sign(JumubaseWeb.Endpoint, %{"email" => email})
  end

  def assert_unauthorized_user(conn) do
    assert get_flash(conn, :error) =~ "not authorized"
    assert redirected_to(conn) == Routes.internal_page_path(conn, :home)
    assert conn.halted
  end

  def assert_unauthorized_guest(conn) do
    assert get_flash(conn, :error) =~ "need to log in"
    assert redirected_to(conn) == Routes.session_path(conn, :new)
    assert conn.halted
  end
end
