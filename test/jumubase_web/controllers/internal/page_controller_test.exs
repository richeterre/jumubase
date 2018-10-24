defmodule JumubaseWeb.Internal.PageControllerTest do
  use JumubaseWeb.ConnCase

  setup config do
    login_if_needed(config)
  end

  describe "for any signed-in user" do
    for role <- all_roles() do
      @tag login_as: role
      test "(#{role}) shows the welcome page with a greeting", %{conn: conn, user: user} do
        conn = get(conn, internal_page_path(conn, :home))
        assert html_response(conn, 200) =~ "Hello #{user.first_name}"
      end
    end
  end

  describe "for a non-admin" do
    for role <- non_admin_roles() do
      @tag login_as: role
      test "(#{role}) does not show admin tools", %{conn: conn} do
        conn = get(conn, internal_page_path(conn, :home))
        refute html_response(conn, 200) =~ "Admin"
      end
    end
  end

  describe "for an admin" do
    @tag login_as: "admin"
    test "shows admin tools", %{conn: conn} do
      conn = get(conn, internal_page_path(conn, :home))
      assert html_response(conn, 200) =~ "Admin"
    end
  end

  describe "for a guest" do
    test "redirects to the login page", %{conn: conn} do
      conn = get(conn, internal_page_path(conn, :home))
      assert_unauthorized_guest(conn)
    end
  end
end
