defmodule JumubaseWeb.Internal.UserControllerTest do
  use JumubaseWeb.ConnCase
  alias Jumubase.Repo
  alias Jumubase.Accounts.User

  @update_attrs %{
    email: "xyz@de.fi",
    given_name: "X Y",
    family_name: "Z",
    role: "global-organizer"
  }
  @invalid_attrs %{email: nil, given_name: nil, family_name: nil, password_hash: nil, role: nil}

  setup config do
    login_if_needed(config)
  end

  describe "for an admin" do
    @describetag login_as: "admin"

    test "lists all users", %{conn: conn} do
      conn = get(conn, Routes.internal_user_path(conn, :index))
      assert html_response(conn, 200) =~ "Users"
    end

    test "renders new user form", %{conn: conn} do
      conn = get(conn, Routes.internal_user_path(conn, :new))
      assert html_response(conn, 200) =~ "New User"
    end

    test "redirects to user list after creating a user", %{conn: conn} do
      valid_attrs = params_for(:user, password: "password")
      conn = post(conn, Routes.internal_user_path(conn, :create), user: valid_attrs)
      assert redirected_to(conn) == Routes.internal_user_path(conn, :index)
    end

    test "renders errors when user creation fails with invalid data", %{conn: conn} do
      conn = post(conn, Routes.internal_user_path(conn, :create), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "New User"
    end

    test "renders user edit form", %{conn: conn} do
      user = insert(:user)

      conn = get(conn, Routes.internal_user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "redirects to user list after editing a user", %{conn: conn} do
      user = insert(:user)

      conn = put(conn, Routes.internal_user_path(conn, :update, user), user: @update_attrs)
      assert redirected_to(conn) == Routes.internal_user_path(conn, :index)

      conn = get(conn, Routes.internal_user_path(conn, :index))
      assert html_response(conn, 200) =~ @update_attrs[:email]
    end

    test "renders errors when user editing fails with invalid data", %{conn: conn} do
      user = insert(:user)

      conn = put(conn, Routes.internal_user_path(conn, :update, user), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "deletes a user", %{conn: conn} do
      user = insert(:user)

      conn = delete(conn, Routes.internal_user_path(conn, :delete, user))
      assert redirected_to(conn) == Routes.internal_user_path(conn, :index)
      refute Repo.get(User, user.id)

      assert_error_sent(404, fn ->
        get(conn, Routes.internal_user_path(conn, :edit, user))
      end)
    end

    test "impersonates another user", %{conn: conn, user: original_user} do
      other_user = insert(:user)

      conn = get(conn, Routes.internal_user_impersonate_path(conn, :impersonate, other_user))

      # At this point the original user is still logged in
      assert conn.assigns.current_user == original_user
      assert redirected_to(conn) == Routes.internal_page_path(conn, :home)

      # Do another request to check if other user was logged in
      conn = get(conn, "/")
      assert conn.assigns.current_user == other_user
    end
  end

  describe "for a non-admin" do
    for role <- roles_except("admin") do
      @tag login_as: role
      test "(#{role}) redirects when trying to perform any action", %{conn: conn} do
        verify_all_routes(conn, &assert_unauthorized_user/1)
      end
    end
  end

  describe "for a guest" do
    test "redirects when trying to perform any action", %{conn: conn} do
      verify_all_routes(conn, &assert_unauthorized_guest/1)
    end
  end

  # Private helpers

  defp verify_all_routes(conn, assertion_fun) do
    user = insert(:user)

    Enum.each(
      [
        get(conn, Routes.internal_user_path(conn, :index)),
        get(conn, Routes.internal_user_path(conn, :new)),
        post(conn, Routes.internal_user_path(conn, :create), %{user: %{}}),
        get(conn, Routes.internal_user_path(conn, :edit, user.id)),
        put(conn, Routes.internal_user_path(conn, :update, user.id, %{user: %{"email" => ""}})),
        delete(conn, Routes.internal_user_path(conn, :delete, user.id)),
        get(conn, Routes.internal_user_impersonate_path(conn, :impersonate, user.id))
      ],
      fn conn ->
        assertion_fun.(conn)
      end
    )
  end
end
