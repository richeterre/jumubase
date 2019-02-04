defmodule JumubaseWeb.Internal.ContestControllerTest do
  use JumubaseWeb.ConnCase
  import JumubaseWeb.Internal.ContestView, only: [name: 1, name_with_flag: 1]

  setup config do
    login_if_needed(config)
  end

  describe "index/2" do
    for role <- roles_except("local-organizer") do
      @tag login_as: role
      test "lists all contests to #{role} users", %{conn: conn, user: u} do
        c1 = insert(:contest, host: build(:host, users: [u]))
        c2 = insert(:contest)
        conn = get(conn, Routes.internal_contest_path(conn, :index))
        assert html_response(conn, 200) =~ "Contests"
        assert html_response(conn, 200) =~ name(c1)
        assert html_response(conn, 200) =~ name(c2)
      end
    end

    @tag login_as: "local-organizer"
    test "lists own contest to local organizers", %{conn: conn, user: u} do
      c1 = insert(:contest, host: build(:host, users: [u]))
      c2 = insert(:contest)
      conn = get(conn, Routes.internal_contest_path(conn, :index))
      assert html_response(conn, 200) =~ "Contests"
      assert html_response(conn, 200) =~ name(c1)
      refute html_response(conn, 200) =~ name(c2)
    end

    test "redirects guests when trying to list all contests", %{conn: conn} do
      conn = get(conn, Routes.internal_contest_path(conn, :index))
      assert_unauthorized_guest(conn)
    end
  end

  describe "show/2" do
    @tag login_as: "local-organizer"
    test "shows an own contest to local organizers", %{conn: conn, user: u} do
      contest = insert(:contest, host: build(:host, users: [u]))
      conn = get(conn, Routes.internal_contest_path(conn, :show, contest))
      assert html_response(conn, 200) =~ name(contest)
    end

    @tag login_as: "local-organizer"
    test "redirects local organizers when trying to view a foreign contest", %{conn: conn} do
      contest = insert(:contest)
      conn = get(conn, Routes.internal_contest_path(conn, :show, contest))
      assert_unauthorized_user(conn)
    end

    for role <- roles_except("local-organizer") do
      @tag login_as: role
      test "shows a single contest to #{role} users", %{conn: conn} do
        contest = insert(:contest)
        conn = get(conn, Routes.internal_contest_path(conn, :show, contest))
        assert html_response(conn, 200) =~ name(contest)
      end
    end

    test "redirects guests when trying to view a contest", %{conn: conn} do
      contest = insert(:contest)
      conn = get(conn, Routes.internal_contest_path(conn, :show, contest))
      assert_unauthorized_guest(conn)
    end
  end

  describe "edit/2" do
    setup do
      [contest: insert(:contest)]
    end

    @tag login_as: "admin"
    test "shows a contest edit form to admins", %{conn: conn, contest: c} do
      conn = get(conn, Routes.internal_contest_path(conn, :edit, c))
      assert html_response(conn, 200) =~ "Edit Contest"
      assert html_response(conn, 200) =~ name_with_flag(c)
    end

    for role <- roles_except("admin") do
      @tag login_as: role
      test "redirects #{role} users when trying to edit a contest", %{conn: conn, contest: c} do
        conn = get(conn, Routes.internal_contest_path(conn, :edit, c))
        assert_unauthorized_user(conn)
      end
    end
  end

  describe "update/2" do
    setup do
      c = insert(:contest, deadline: ~D[2018-12-15])
      params = %{"contest" => %{"deadline" => "2018-12-01"}}
      [contest: c, params: params]
    end

    @tag login_as: "admin"
    test "lets admins updates a contest", %{conn: conn, contest: c, params: params} do
      conn = put(conn, Routes.internal_contest_path(conn, :update, c, params))
      redirect_path = Routes.internal_contest_path(conn, :index)

      assert redirected_to(conn) == redirect_path
      # Follow redirection
      conn = get(recycle(conn), redirect_path)
      assert html_response(conn, 200) =~ "The contest #{name(c)} was updated."
    end

    @tag login_as: "admin"
    test "shows form to admins for invalid input", %{conn: conn, contest: c} do
      invalid_params = %{"contest" => %{"season" => ""}}
      conn = put(conn, Routes.internal_contest_path(conn, :update, c, invalid_params))
      assert html_response(conn, 200) =~ "Edit Contest"
    end

    for role <- roles_except("admin") do
      @tag login_as: role
      test "redirects #{role} users when trying to update a contest", %{
        conn: conn,
        contest: c,
        params: params
      } do
        conn = put(conn, Routes.internal_contest_path(conn, :update, c, params))
        assert_unauthorized_user(conn)
      end
    end
  end
end
