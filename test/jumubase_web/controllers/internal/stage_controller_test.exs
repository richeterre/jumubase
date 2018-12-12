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
        conn = get(conn, Routes.internal_contest_stage_path(conn, :index, c))
        assert html_response(conn, 200) =~ "Schedule performances"
      end
    end

    @tag login_as: "local-organizer"
    test "lists an own contest's stages to local organizers", %{conn: conn, user: u} do
      own_c = insert_own_contest(u)
      conn = get(conn, Routes.internal_contest_stage_path(conn, :index, own_c))
      assert html_response(conn, 200) =~ "Schedule performances"
    end

    @tag login_as: "local-organizer"
    test "redirects local organizers when trying to list a foreign contest's stages", %{conn: conn, contest: c} do
      conn = get(conn, Routes.internal_contest_stage_path(conn, :index, c))
      assert_unauthorized_user(conn)
    end

    test "redirects guests when trying to list a contest's stages", %{conn: conn, contest: c} do
      conn = get(conn, Routes.internal_contest_stage_path(conn, :index, c))
      assert_unauthorized_guest(conn)
    end
  end

  describe "schedule/2" do
    setup %{contest: c} do
      [contest: c, stage: insert(:stage, host: c.host)]
    end

    for role <- roles_except("local-organizer") do
      @tag login_as: role
      test "lets #{role} users schedule a contest's performances", %{conn: conn, contest: c, stage: s} do
        conn = get(conn, Routes.internal_contest_stage_schedule_path(conn, :schedule, c, s))
        assert html_response(conn, 200) =~ "Schedule performances: #{s.name}"
      end
    end

    @tag login_as: "local-organizer"
    test "lets local organizers schedule an own contest's performances", %{conn: conn, user: u} do
      own_c = insert_own_contest(u)
      own_s = insert(:stage, host: own_c.host)
      conn = get(conn, Routes.internal_contest_stage_schedule_path(conn, :schedule, own_c, own_s))
      assert html_response(conn, 200) =~ "Schedule performances: #{own_s.name}"
    end

    @tag login_as: "local-organizer"
    test "redirects local organizers when trying to schedule a foreign contest's performances", %{conn: conn, contest: c, stage: s} do
      conn = get(conn, Routes.internal_contest_stage_schedule_path(conn, :schedule, c, s))
      assert_unauthorized_user(conn)
    end

    test "redirects guests when trying to schedule a contest's performances", %{conn: conn, contest: c, stage: s} do
      conn = get(conn, Routes.internal_contest_stage_schedule_path(conn, :schedule, c, s))
      assert_unauthorized_guest(conn)
    end
  end

  # Private helpers

  # TODO: Reuse
  defp insert_own_contest(user) do
    insert(:contest, host: insert(:host, users: [user]))
  end
end
