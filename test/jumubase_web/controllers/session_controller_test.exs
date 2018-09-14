defmodule JumubaseWeb.SessionControllerTest do
  use JumubaseWeb.ConnCase

  import JumubaseWeb.AuthCase
  alias Jumubase.Accounts

  @valid_attrs %{email: "user@example.com", password: "reallyHard2gue$$"}
  @invalid_attrs %{email: "user@example.com", password: "cannotGue$$it"}
  @rem_attrs Map.merge(@valid_attrs, %{remember_me: "true"})
  @no_rem_attrs Map.merge(@valid_attrs, %{remember_me: "false"})

  setup %{conn: conn} do
    conn = conn |> bypass_through(JumubaseWeb.Router, [:browser]) |> get("/")
    user = add_user(@valid_attrs[:email])
    {:ok, %{conn: conn, user: user}}
  end

  test "rendering login form fails for user that is already logged in", %{conn: conn, user: user} do
    conn = conn |> add_phauxth_session(user) |> send_resp(:ok, "/")
    conn = get(conn, session_path(conn, :new))
    assert redirected_to(conn) == page_path(conn, :home)
  end

  test "login succeeds", %{conn: conn} do
    conn = post(conn, session_path(conn, :create), session: @valid_attrs)
    assert redirected_to(conn) == internal_page_path(conn, :home)
  end

  test "login fails for user that is already logged in", %{conn: conn, user: user} do
    conn = conn |> add_phauxth_session(user) |> send_resp(:ok, "/")
    conn = post(conn, session_path(conn, :create), session: @valid_attrs)
    assert redirected_to(conn) == page_path(conn, :home)
  end

  test "login fails for invalid password", %{conn: conn} do
    conn = post(conn, session_path(conn, :create), session: @invalid_attrs)
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "logout succeeds and session is deleted", %{conn: conn, user: user} do
    conn = conn |> add_phauxth_session(user) |> send_resp(:ok, "/")
    conn = delete(conn, session_path(conn, :delete, user))
    assert redirected_to(conn) == page_path(conn, :home)
    conn = get(conn, internal_page_path(conn, :home))
    assert redirected_to(conn) == session_path(conn, :new)
    assert Accounts.list_sessions(user.id) == %{}
  end

  test "redirects to previously requested resource", %{conn: conn} do
    requested_path = internal_user_path(conn, :index)
    conn = get(conn, requested_path)
    assert redirected_to(conn) == session_path(conn, :new)
    conn = post(conn, session_path(conn, :create), session: @valid_attrs)
    assert redirected_to(conn) == requested_path
  end

  test "remember me cookie is added / not added", %{conn: conn} do
    rem_conn = post(conn, session_path(conn, :create), session: @rem_attrs)
    assert rem_conn.resp_cookies["remember_me"]
    no_rem_conn = post(conn, session_path(conn, :create), session: @no_rem_attrs)
    refute no_rem_conn.resp_cookies["remember_me"]
  end
end
