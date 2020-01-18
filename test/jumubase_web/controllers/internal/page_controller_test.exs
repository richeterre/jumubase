defmodule JumubaseWeb.Internal.PageControllerTest do
  use JumubaseWeb.ConnCase
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]

  setup config do
    login_if_needed(config)
  end

  describe "home/2" do
    for role <- all_roles() do
      @tag login_as: role
      test "greets #{role} users on the welcome page", %{conn: conn, user: user} do
        conn = get(conn, Routes.internal_page_path(conn, :home))
        assert html_response(conn, 200) =~ "Hello #{user.given_name}"
      end
    end

    @tag login_as: "local-organizer"
    test "shows all authorized contests to a local organizer", %{conn: conn, user: u} do
      h1 = build(:host, current_grouping: "1", users: [u])
      h2 = build(:host, current_grouping: "2", users: [u])

      # Matching contests
      c1 = insert(:contest, round: 0, grouping: "1", host: h1)
      c2 = insert(:contest, round: 1, grouping: "1", host: h1)
      c3 = insert(:contest, round: 2, grouping: "1", host: h1)
      c4 = insert(:contest, round: 0, grouping: "2", host: h2)
      c5 = insert(:contest, round: 1, grouping: "3", host: h2)

      # Non-matching contests
      c6 = insert(:contest, grouping: "1", round: 0)
      c7 = insert(:contest, grouping: "1", round: 1)
      c8 = insert(:contest, grouping: "2", round: 2)
      c9 = insert(:contest, grouping: "3", round: 2)

      conn = get(conn, Routes.internal_page_path(conn, :home))

      assert_contests_listed(conn, [c1, c2, c3, c4, c5])
      refute_contests_listed(conn, [c6, c7, c8, c9])
    end

    for role <- roles_except("local-organizer") do
      @tag login_as: role
      test "shows relevant contests to a #{role} user", %{conn: conn, user: u} do
        h1 = build(:host, current_grouping: "1", users: [u])
        h2 = build(:host, current_grouping: "2", users: [u])

        # Matching contests
        c1 = insert(:contest, round: 0, grouping: "1", host: h1)
        c2 = insert(:contest, round: 1, grouping: "1", host: h1)
        c3 = insert(:contest, round: 2, grouping: "1", host: h1)
        c4 = insert(:contest, round: 1, grouping: "2", host: h2)
        c5 = insert(:contest, round: 2, grouping: "2")

        # Non-matching contests (not relevant enough)
        c6 = insert(:contest, round: 0, grouping: "1")
        c7 = insert(:contest, round: 1, grouping: "1")

        conn = get(conn, Routes.internal_page_path(conn, :home))

        assert_contests_listed(conn, [c1, c2, c3, c4, c5])
        refute_contests_listed(conn, [c6, c7])
      end
    end

    @tag login_as: "global-organizer"
    test "contains a 'Show more' link when not listing all contests", %{conn: conn, user: u} do
      insert(:contest, round: 1, host: build(:host, users: [u]))
      insert(:contest, round: 1)
      conn = get(conn, Routes.internal_page_path(conn, :home))
      assert html_response(conn, 200) =~ "Show more…"
    end

    @tag login_as: "global-organizer"
    test "does not contain a 'Show more' link when listing all contests", %{conn: conn, user: u} do
      insert(:contest, round: 1, host: build(:host, users: [u]))
      conn = get(conn, Routes.internal_page_path(conn, :home))
      refute html_response(conn, 200) =~ "Show more…"
    end

    @tag login_as: "admin"
    test "shows admin tools to admins", %{conn: conn} do
      conn = get(conn, Routes.internal_page_path(conn, :home))
      assert html_response(conn, 200) =~ "Admin"
    end

    for role <- roles_except("admin") do
      @tag login_as: role
      test "shows no admin tools to #{role} users", %{conn: conn} do
        conn = get(conn, Routes.internal_page_path(conn, :home))
        refute html_response(conn, 200) =~ "Admin"
      end
    end

    test "redirects guests to the login page", %{conn: conn} do
      conn = get(conn, Routes.internal_page_path(conn, :home))
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
