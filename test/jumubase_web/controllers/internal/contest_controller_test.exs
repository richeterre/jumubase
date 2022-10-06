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

  describe "update_timetables_public/2" do
    for role <- roles_except("observer") do
      @tag login_as: role
      test "lets #{role} users publish an authorized contest's timetables", %{conn: conn, user: u} do
        contest = insert_authorized_contest(u)
        conn = attempt_update_timetables_public(conn, contest, true)

        redirect_path = Routes.internal_contest_stage_path(conn, :index, contest)
        assert redirected_to(conn) == redirect_path

        # Follow redirection
        conn = get(recycle(conn), redirect_path)

        assert html_response(conn, 200) =~
                 "Your timetables are now publicly visible through the mobile app “Jumu weltweit”."
      end

      @tag login_as: role
      test "lets #{role} users unpublish an authorized contest's timetables",
           %{conn: conn, user: u} do
        contest = insert_authorized_contest(u)
        conn = attempt_update_timetables_public(conn, contest, false)

        redirect_path = Routes.internal_contest_stage_path(conn, :index, contest)
        assert redirected_to(conn) == redirect_path

        # Follow redirection
        conn = get(recycle(conn), redirect_path)

        assert html_response(conn, 200) =~
                 "Once you’re done scheduling for all stages, you can publish your timetables here."
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects #{role} users trying to publish an unauthorized contests' timetables",
           %{conn: conn, user: u} do
        contest = insert_unauthorized_contest(u)
        conn = attempt_update_timetables_public(conn, contest, true)
        assert_unauthorized_user(conn)
      end

      @tag login_as: role
      test "redirects #{role} users trying to unpublish an unauthorized contests' timetables",
           %{conn: conn, user: u} do
        contest = insert_unauthorized_contest(u)
        conn = attempt_update_timetables_public(conn, contest, false)
        assert_unauthorized_user(conn)
      end
    end

    @tag login_as: "observer"
    test "redirects observers trying to publish timetables for a contest", %{conn: conn} do
      contest = insert(:contest)
      conn = attempt_update_timetables_public(conn, contest, true)
      assert_unauthorized_user(conn)
    end

    @tag login_as: "observer"
    test "redirects observers trying to unpublish timetables for a contest", %{conn: conn} do
      contest = insert(:contest)
      conn = attempt_update_timetables_public(conn, contest, false)
      assert_unauthorized_user(conn)
    end

    test "redirects guests trying to publish timetables for a contest", %{conn: conn} do
      contest = insert(:contest)
      conn = attempt_update_timetables_public(conn, contest, true)
      assert_unauthorized_guest(conn)
    end

    test "redirects guests trying to unpublish timetables for a contest", %{conn: conn} do
      contest = insert(:contest)
      conn = attempt_update_timetables_public(conn, contest, false)
      assert_unauthorized_guest(conn)
    end
  end

  # Private helpers

  defp attempt_update_timetables_public(conn, contest, value) do
    route =
      Routes.internal_contest_update_timetables_public_path(
        conn,
        :update_timetables_public,
        contest,
        %{"public" => value}
      )

    patch(conn, route)
  end
end
