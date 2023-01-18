defmodule JumubaseWeb.Internal.StageControllerTest do
  use JumubaseWeb.ConnCase

  setup config do
    config
    |> Map.put(:contest, insert(:contest))
    |> login_if_needed
  end

  describe "index/2" do
    for role <- all_roles() do
      @tag login_as: role
      test "lists a contest's stages to authorized #{role} users", %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        conn |> attempt_index(c) |> assert_index_success
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to list a contest's stages",
           %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u)
        conn |> attempt_index(c) |> assert_unauthorized_user
      end
    end

    test "redirects guests trying to list a contest's stages", %{conn: conn, contest: c} do
      conn |> attempt_index(c) |> assert_unauthorized_guest
    end
  end

  describe "new/3" do
    for role <- roles_except("observer") do
      @tag login_as: role
      test "lets authorized #{role} users fill in a new stage", %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        conn = conn |> attempt_new(c)
        assert html_response(conn, 200) =~ "New Stage"
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to fill in a new stage",
           %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u)
        conn |> attempt_new(c) |> assert_unauthorized_user
      end
    end

    @tag login_as: "observer"
    test "redirects observers trying to fill in a new stage", %{conn: conn, contest: c} do
      conn |> attempt_new(c) |> assert_unauthorized_user
    end

    test "redirects guests trying to fill in a new stage", %{conn: conn, contest: c} do
      conn |> attempt_new(c) |> assert_unauthorized_guest
    end
  end

  @create_attrs %{name: "New name"}

  describe "create/3" do
    for role <- roles_except("observer") do
      @tag login_as: role
      test "lets authorized #{role} users create a new stage", %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        conn = attempt_create(conn, c)
        assert_create_success(conn, c)
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to create a new stage",
           %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u)
        conn |> attempt_create(c) |> assert_unauthorized_user
      end
    end

    @tag login_as: "observer"
    test "redirects observers trying to create a new stage", %{conn: conn, contest: c} do
      conn |> attempt_create(c) |> assert_unauthorized_user
    end

    test "redirects guests trying to create a new stage", %{conn: conn, contest: c} do
      conn |> attempt_create(c) |> assert_unauthorized_guest
    end
  end

  describe "schedule/2" do
    for role <- all_roles() do
      @tag login_as: role
      test "lets authorized #{role} users schedule a contest's performances",
           %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        s = insert(:stage, host: c.host)
        conn |> attempt_schedule(c, s) |> assert_schedule_success(s)
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to schedule a contest's performances",
           %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u)
        s = insert(:stage, host: c.host)
        conn |> attempt_schedule(c, s) |> assert_unauthorized_user
      end
    end

    test "redirects guests trying to schedule a contest's performances", %{conn: conn, contest: c} do
      s = insert(:stage, host: c.host)
      conn |> attempt_schedule(c, s) |> assert_unauthorized_guest
    end
  end

  describe "timetable/2" do
    for role <- all_roles() do
      @tag login_as: role
      test "lets authorized #{role} users view a contest stage's timetable",
           %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        s = insert(:stage, host: c.host)
        conn |> attempt_timetable(c, s) |> assert_timetable_success(s)
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to view a contest stage's timetable",
           %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u)
        s = insert(:stage, host: c.host)
        conn |> attempt_timetable(c, s) |> assert_unauthorized_user
      end
    end

    test "redirects guests trying to view a contest stage's timetable", %{conn: conn, contest: c} do
      s = insert(:stage, host: c.host)
      conn |> attempt_timetable(c, s) |> assert_unauthorized_guest
    end
  end

  # Private helpers

  defp attempt_index(conn, contest) do
    get(conn, Routes.internal_contest_stage_path(conn, :index, contest))
  end

  defp assert_index_success(conn) do
    assert html_response(conn, 200) =~ "Schedule performances"
  end

  defp attempt_new(conn, contest) do
    get(conn, Routes.internal_contest_stage_path(conn, :new, contest))
  end

  defp attempt_create(conn, contest) do
    valid_attrs = params_for(:stage, @create_attrs)
    post(conn, Routes.internal_contest_stage_path(conn, :create, contest), stage: valid_attrs)
  end

  defp assert_create_success(conn, contest) do
    redirect_path = Routes.internal_contest_stage_path(conn, :index, contest)
    assert redirected_to(conn) == redirect_path
    # Follow redirection
    conn = get(recycle(conn), redirect_path)
    assert html_response(conn, 200) =~ @create_attrs[:name]
  end

  defp attempt_schedule(conn, contest, stage) do
    get(conn, Routes.internal_contest_stage_schedule_path(conn, :schedule, contest, stage))
  end

  defp assert_schedule_success(conn, stage) do
    assert html_response(conn, 200) =~ "Schedule performances: #{stage.name}"
  end

  defp attempt_timetable(conn, contest, stage) do
    get(conn, Routes.internal_contest_stage_timetable_path(conn, :timetable, contest, stage))
  end

  defp assert_timetable_success(conn, stage) do
    assert html_response(conn, 200) =~ "Timetable: #{stage.name}"
  end
end
