defmodule JumubaseWeb.Internal.ContestControllerTest do
  use JumubaseWeb.ConnCase
  import JumubaseWeb.Internal.ContestView, only: [name: 1, name_with_flag: 1]
  alias JumubaseWeb.Internal.ContestLive

  setup config do
    login_if_needed(config)
  end

  describe "show/2" do
    for role <- all_roles() do
      @tag login_as: role
      test "shows a single authorized contest to #{role} users", %{conn: conn, user: u} do
        contest = insert_authorized_contest(u)
        conn = get(conn, Routes.internal_contest_path(conn, :show, contest))
        assert html_response(conn, 200) =~ name(contest)
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects #{role} users trying to view an unauthorized contest",
           %{conn: conn, user: u} do
        contest = insert_unauthorized_contest(u)
        conn = get(conn, Routes.internal_contest_path(conn, :show, contest))
        assert_unauthorized_user(conn)
      end
    end

    test "redirects guests trying to view a contest", %{conn: conn} do
      contest = insert(:contest)
      conn = get(conn, Routes.internal_contest_path(conn, :show, contest))
      assert_unauthorized_guest(conn)
    end
  end

  describe "new/2" do
    @tag login_as: "admin"
    test "lets admins fill in new contest data", %{conn: conn} do
      conn = get(conn, Routes.internal_contest_path(conn, :new))
      assert html_response(conn, 200) =~ "New Contest"
    end

    for role <- roles_except("admin") do
      @tag login_as: role
      test "redirects #{role} users trying to fill in new contest data", %{conn: conn} do
        conn = get(conn, Routes.internal_contest_path(conn, :new))
        assert_unauthorized_user(conn)
      end
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
      test "redirects #{role} users trying to edit a contest", %{conn: conn, contest: c} do
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
    test "lets admins update a contest", %{conn: conn, contest: c, params: params} do
      conn = put(conn, Routes.internal_contest_path(conn, :update, c, params))

      redirect_path = Routes.internal_live_path(conn, ContestLive.Index)
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
      test "redirects #{role} users trying to update a contest", %{
        conn: conn,
        contest: c,
        params: params
      } do
        conn = put(conn, Routes.internal_contest_path(conn, :update, c, params))
        assert_unauthorized_user(conn)
      end
    end
  end

  describe "delete/2" do
    setup do
      [contest: insert(:contest)]
    end

    @tag login_as: "admin"
    test "lets admins delete a contest", %{conn: conn, contest: c} do
      conn = delete(conn, Routes.internal_contest_path(conn, :delete, c))

      redirect_path = Routes.internal_live_path(conn, ContestLive.Index)
      assert redirected_to(conn) == redirect_path

      # Follow redirection
      conn = get(recycle(conn), redirect_path)

      assert html_response(conn, 200) =~ "The contest #{name(c)} was deleted."
    end

    for role <- roles_except("admin") do
      @tag login_as: role
      test "redirects #{role} users trying to delete a contest", %{conn: conn, contest: c} do
        conn = delete(conn, Routes.internal_contest_path(conn, :delete, c))
        assert_unauthorized_user(conn)
      end
    end
  end
end
