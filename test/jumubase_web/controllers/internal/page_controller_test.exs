defmodule JumubaseWeb.Internal.PageControllerTest do
  use JumubaseWeb.ConnCase
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]

  setup config do
    login_if_needed(config)
  end

  describe "home page" do
    for role <- all_roles() do
      @tag login_as: role
      test "greets #{role} users on the welcome page", %{conn: conn, user: user} do
        conn = get(conn, internal_page_path(conn, :home))
        assert html_response(conn, 200) =~ "Hello #{user.given_name}"
      end
    end

    @tag login_as: "local-organizer"
    test "shows own contests to a local organizer", %{conn: conn, user: u} do
      own_c = insert(:contest, host: build(:host, users: [u]))
      other_c = insert(:contest)

      conn = get(conn, internal_page_path(conn, :home))
      assert html_response(conn, 200) =~ name_with_flag(own_c)
      refute html_response(conn, 200) =~ name_with_flag(other_c)
    end

    for role <- roles_except("local-organizer") do
      @tag login_as: role
      test "shows all contests to a #{role} user", %{conn: conn, user: u} do
        own_c = insert(:contest, host: build(:host, users: [u]))
        other_c = insert(:contest)

        conn = get(conn, internal_page_path(conn, :home))
        assert html_response(conn, 200) =~ name_with_flag(own_c)
        assert html_response(conn, 200) =~ name_with_flag(other_c)
      end
    end

    @tag login_as: "admin"
    test "shows admin tools to admins", %{conn: conn} do
      conn = get(conn, internal_page_path(conn, :home))
      assert html_response(conn, 200) =~ "Admin"
    end

    for role <- roles_except("admin") do
      @tag login_as: role
      test "shows no admin tools to #{role} users", %{conn: conn} do
        conn = get(conn, internal_page_path(conn, :home))
        refute html_response(conn, 200) =~ "Admin"
      end
    end

    test "redirects guests to the login page", %{conn: conn} do
      conn = get(conn, internal_page_path(conn, :home))
      assert_unauthorized_guest(conn)
    end
  end
end
