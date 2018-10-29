defmodule JumubaseWeb.Internal.ContestControllerTest do
  use JumubaseWeb.ConnCase
  import JumubaseWeb.Internal.ContestView, only: [name: 1]

  setup config do
    login_if_needed(config)
  end

  describe "index/2" do
    for role <- roles_except("local-organizer") do
      @tag login_as: role
      test "lists all contests to #{role} users", %{conn: conn, user: u} do
        c1 = insert(:contest, host: build(:host, users: [u]))
        c2 = insert(:contest)
        conn = get(conn, internal_contest_path(conn, :index))
        assert html_response(conn, 200) =~ "Contests"
        assert html_response(conn, 200) =~ name(c1)
        assert html_response(conn, 200) =~ name(c2)
      end
    end

    @tag login_as: "local-organizer"
    test "lists own contest to local organizers", %{conn: conn, user: u} do
      c1 = insert(:contest, host: build(:host, users: [u]))
      c2 = insert(:contest)
      conn = get(conn, internal_contest_path(conn, :index))
      assert html_response(conn, 200) =~ "Contests"
      assert html_response(conn, 200) =~ name(c1)
      refute html_response(conn, 200) =~ name(c2)
    end

    test "redirects guests when trying to list all contests", %{conn: conn} do
      conn = get(conn, internal_contest_path(conn, :index))
      assert_unauthorized_guest(conn)
    end
  end

  describe "show/2" do
    @tag login_as: "local-organizer"
    test "shows an own contest to local organizers", %{conn: conn, user: u} do
      contest = insert(:contest, host: build(:host, users: [u]))
      conn = get(conn, internal_contest_path(conn, :show, contest))
      assert html_response(conn, 200) =~ name(contest)
    end

    @tag login_as: "local-organizer"
    test "redirects local organizers when trying to view a foreign contest", %{conn: conn} do
      contest = insert(:contest)
      conn = get(conn, internal_contest_path(conn, :show, contest))
      assert_unauthorized_user(conn)
    end

    for role <- roles_except("local-organizer") do
      @tag login_as: role
      test "shows a single contest to #{role} users", %{conn: conn} do
        contest = insert(:contest)
        conn = get(conn, internal_contest_path(conn, :show, contest))
        assert html_response(conn, 200) =~ name(contest)
      end
    end

    test "redirects guests when trying to view a contest", %{conn: conn} do
      contest = insert(:contest)
      conn = get(conn, internal_contest_path(conn, :show, contest))
      assert_unauthorized_guest(conn)
    end
  end
end
