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
      own_host = build(:host, users: [u])
      own_kimu = insert(:contest, round: 0, host: own_host)
      own_rw = insert(:contest, round: 1, host: own_host)
      own_lw = insert(:contest, round: 2, host: own_host)
      other_kimu = insert(:contest, round: 0)
      other_rw = insert(:contest, round: 1)
      other_lw = insert(:contest, round: 2)

      conn = get(conn, internal_page_path(conn, :home))

      assert_contests_listed(conn, [own_kimu, own_rw, own_lw])
      refute_contests_listed(conn, [other_kimu, other_rw, other_lw])
    end

    for role <- roles_except("local-organizer") do
      @tag login_as: role
      test "shows relevant contests to a #{role} user", %{conn: conn, user: u} do
        own_host = build(:host, users: [u])
        own_kimu = insert(:contest, round: 0, host: own_host)
        own_rw = insert(:contest, round: 1, host: own_host)
        own_lw = insert(:contest, round: 2, host: own_host)
        other_kimu = insert(:contest, round: 0)
        other_rw = insert(:contest, round: 1)
        other_lw = insert(:contest, round: 2)

        conn = get(conn, internal_page_path(conn, :home))

        assert_contests_listed(conn, [own_kimu, own_rw, own_lw, other_lw])
        refute_contests_listed(conn, [other_kimu, other_rw])
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

  # Private helpers

  defp assert_contests_listed(conn, contests) do
    Enum.each(contests, fn c ->
      assert is_listed?(conn, c)
    end)
  end

  defp refute_contests_listed(conn, contests) do
    Enum.each(contests, fn c ->
      refute is_listed?(conn, c)
    end)
  end

  defp is_listed?(conn, contest) do
    html_response(conn, 200) =~ name_with_flag(contest)
  end
end
