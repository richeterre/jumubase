defmodule JumubaseWeb.Internal.StageControllerTest do
  use JumubaseWeb.ConnCase

  setup config do
    config
    |> Map.put(:contest, insert(:contest))
    |> login_if_needed
  end

  describe "index/2" do
    for role <- roles_except("local-organizer") do
      @tag login_as: role
      test "lists a contest's stages to #{role} users", %{conn: conn, contest: c} do
        conn |> attempt_index(c) |> assert_index_success
      end
    end

    @tag login_as: "local-organizer"
    test "lists an own contest's stages to local organizers", %{conn: conn, user: u} do
      own_c = insert_own_contest(u)
      conn |> attempt_index(own_c) |> assert_index_success
    end

    @tag login_as: "local-organizer"
    test "redirects local organizers when trying to list a foreign contest's stages", %{conn: conn, contest: c} do
      conn |> attempt_index(c) |> assert_unauthorized_user
    end

    test "redirects guests when trying to list a contest's stages", %{conn: conn, contest: c} do
      conn |> attempt_index(c) |> assert_unauthorized_guest
    end
  end

  describe "schedule/2" do
    setup %{contest: c} do
      [contest: c, stage: insert(:stage, host: c.host)]
    end

    for role <- roles_except("local-organizer") do
      @tag login_as: role
      test "lets #{role} users schedule a contest's performances", %{conn: conn, contest: c, stage: s} do
        conn |> attempt_schedule(c, s) |> assert_schedule_success(s)
      end
    end

    @tag login_as: "local-organizer"
    test "lets local organizers schedule an own contest's performances", %{conn: conn, user: u} do
      own_c = insert_own_contest(u)
      own_s = insert(:stage, host: own_c.host)
      conn |> attempt_schedule(own_c, own_s) |> assert_schedule_success(own_s)
    end

    @tag login_as: "local-organizer"
    test "redirects local organizers when trying to schedule a foreign contest's performances", %{conn: conn, contest: c, stage: s} do
      conn |> attempt_schedule(c, s) |> assert_unauthorized_user
    end

    test "redirects guests when trying to schedule a contest's performances", %{conn: conn, contest: c, stage: s} do
      conn |> attempt_schedule(c, s) |> assert_unauthorized_guest
    end
  end

  describe "timetable/2" do
    setup %{contest: c} do
      [contest: c, stage: insert(:stage, host: c.host)]
    end

    for role <- roles_except("local-organizer") do
      @tag login_as: role
      test "lets #{role} users view a contest stage's timetable", %{conn: conn, contest: c, stage: s} do
        conn |> attempt_timetable(c, s) |> assert_timetable_success(s)
      end
    end

    @tag login_as: "local-organizer"
    test "lets local organizers view an own contest stage's timetable", %{conn: conn, user: u} do
      own_c = insert_own_contest(u)
      own_s = insert(:stage, host: own_c.host)
      conn |> attempt_timetable(own_c, own_s) |> assert_timetable_success(own_s)
    end

    @tag login_as: "local-organizer"
    test "redirects local organizers when trying to view a foreign contest stage's timetable", %{conn: conn, contest: c, stage: s} do
      conn |> attempt_timetable(c, s) |> assert_unauthorized_user
    end

    test "redirects guests when trying to view a contest stage's timetable", %{conn: conn, contest: c, stage: s} do
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
