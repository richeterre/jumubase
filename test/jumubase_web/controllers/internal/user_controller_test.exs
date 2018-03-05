defmodule JumubaseWeb.Internal.UserControllerTest do
  use JumubaseWeb.ConnCase
  alias Jumubase.Factory

  @update_attrs %{email: "xyz@de.fi", first_name: "X Y", last_name: "Z", role: "lw-organizer"}
  @invalid_attrs %{email: nil, first_name: nil, last_name: nil, password_hash: nil, role: nil}

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, internal_user_path(conn, :index))
      assert html_response(conn, 200) =~ "Users"
    end
  end

  describe "new user" do
    test "renders form", %{conn: conn} do
      conn = get(conn, internal_user_path(conn, :new))
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "create user" do
    test "redirects to user list when data is valid", %{conn: conn} do
      valid_attrs = Factory.params_for(:user)
      conn = post(conn, internal_user_path(conn, :create), user: valid_attrs)
      assert redirected_to(conn) == internal_user_path(conn, :index)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, internal_user_path(conn, :create), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "edit user" do
    setup [:create_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get(conn, internal_user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_user]

    test "redirects to user list when data is valid", %{conn: conn, user: user} do
      conn = put(conn, internal_user_path(conn, :update, user), user: @update_attrs)
      assert redirected_to(conn) == internal_user_path(conn, :index)

      conn = get(conn, internal_user_path(conn, :index))
      assert html_response(conn, 200) =~ @update_attrs[:email]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, internal_user_path(conn, :update, user), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, internal_user_path(conn, :delete, user))
      assert redirected_to(conn) == internal_user_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, internal_user_path(conn, :edit, user))
      end)
    end
  end

  defp create_user(_) do
    {:ok, user: Factory.insert(:user)}
  end
end
