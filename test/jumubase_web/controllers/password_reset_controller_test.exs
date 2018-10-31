defmodule JumubaseWeb.PasswordResetControllerTest do
  use JumubaseWeb.ConnCase
  alias Jumubase.Accounts

  @update_attrs %{email: "gladys@example.com", password: "^hEsdg*F899"}

  setup %{conn: conn} do
    conn = conn |> bypass_through(JumubaseWeb.Router, :browser) |> get("/")
    user = add_reset_user("gladys@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  defp get do
    Accounts.get_by(%{"email" => "gladys@example.com"})
  end

  describe "create/2" do
    test "lets the user create a password reset request", %{conn: conn} do
      valid_attrs = %{email: "gladys@example.com"}
      conn = post(conn, password_reset_path(conn, :create), password_reset: valid_attrs)
      assert conn.private.phoenix_flash["info"] =~ "your inbox for instructions"
      assert redirected_to(conn) == session_path(conn, :new)
    end

    test "succeeds even if the user wasn't found", %{conn: conn} do
      invalid_attrs = %{email: "prettylady@example.com"}
      conn = post(conn, password_reset_path(conn, :create), password_reset: invalid_attrs)
      assert conn.private.phoenix_flash["info"] =~ "your inbox for instructions"
      assert redirected_to(conn) == session_path(conn, :new)
    end
  end

  test "reset password succeeds for correct key", %{conn: conn} do
    valid_attrs = Map.put(@update_attrs, :key, gen_key("gladys@example.com"))
    reset_conn = put(conn, password_reset_path(conn, :update), password_reset: valid_attrs)
    assert reset_conn.private.phoenix_flash["info"] =~ "password has been reset"
    assert redirected_to(reset_conn) == session_path(conn, :new)
    conn = post(conn, session_path(conn, :create), session: @update_attrs)
    assert redirected_to(conn) == internal_page_path(conn, :home)
  end

  test "reset password fails for incorrect key", %{conn: conn} do
    invalid_attrs = %{email: "gladys@example.com", password: "^hEsdg*F899", key: "garbage"}
    conn = put(conn, password_reset_path(conn, :update), password_reset: invalid_attrs)
    assert conn.private.phoenix_flash["error"] =~ "Unfortunately, the email or password was incorrect."
  end

  test "sessions are deleted when user updates password", %{conn: conn, user: user} do
    add_phauxth_session(conn, user)
    assert get().sessions != %{}
    valid_attrs = Map.put(@update_attrs, :key, gen_key("gladys@example.com"))
    reset_conn = put(conn, password_reset_path(conn, :update), password_reset: valid_attrs)
    refute get_session(reset_conn, :phauxth_session_id)
    assert get().sessions == %{}
  end
end
