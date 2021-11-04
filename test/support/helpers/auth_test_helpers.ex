defmodule JumubaseWeb.AuthTestHelpers do
  import Phoenix.ConnTest
  import ExUnit.Assertions
  alias JumubaseWeb.Router.Helpers, as: Routes

  def assert_unauthorized_user(conn) do
    assert get_flash(conn, :error) =~ "not authorized"
    assert redirected_to(conn) == Routes.internal_page_path(conn, :home)
    assert conn.halted
  end

  def assert_unauthorized_guest(conn) do
    assert get_flash(conn, :error) =~ "need to log in"
    assert redirected_to(conn) == Routes.user_session_path(conn, :new)
    assert conn.halted
  end
end
