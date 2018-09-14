defmodule JumubaseWeb.Internal.UserControllerTest do
  use JumubaseWeb.ConnCase
  import JumubaseWeb.AuthCase
  alias Jumubase.Factory
  alias Jumubase.Accounts

  @update_attrs %{email: "xyz@de.fi", first_name: "X Y", last_name: "Z", role: "lw-organizer"}
  @invalid_attrs %{email: nil, first_name: nil, last_name: nil, password_hash: nil, role: nil}

  setup %{conn: conn} = config do
    conn = conn |> bypass_through(JumubaseWeb.Router, [:browser]) |> get("/")
    if email = config[:login] do
      user = add_user(email)
      conn = conn |> add_phauxth_session(user) |> send_resp(:ok, "/")
      {:ok, %{conn: conn}}
    else
      {:ok, %{conn: conn}}
    end
  end

  describe "index" do
    @tag login: "admin@example.com"
    test "lists all users", %{conn: conn} do
      conn = get(conn, internal_user_path(conn, :index))
      assert html_response(conn, 200) =~ "Users"
    end

    test "prevents access from guests", %{conn: conn}  do
      conn = get(conn, internal_user_path(conn, :index))
      assert redirected_to(conn) == session_path(conn, :new)
    end
  end

  describe "new user" do
    @describetag login: "admin@example.com"

    test "renders form", %{conn: conn} do
      conn = get(conn, internal_user_path(conn, :new))
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "create user" do
    @describetag login: "admin@example.com"

    test "redirects to user list when data is valid", %{conn: conn} do
      valid_attrs = Factory.params_for(:user, password: "password")
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
    @describetag login: "admin@example.com"

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get(conn, internal_user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_user]
    @describetag login: "admin@example.com"

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
    @describetag login: "admin@example.com"

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, internal_user_path(conn, :delete, user))
      assert redirected_to(conn) == internal_user_path(conn, :index)
      refute Accounts.get(user.id)
      assert_error_sent(404, fn ->
        get(conn, internal_user_path(conn, :edit, user))
      end)
    end
  end

  defp create_user(_) do
    {:ok, user: Factory.insert(:user)}
  end
end
