defmodule JumubaseWeb.Internal.PerformanceControllerTest do
  use JumubaseWeb.ConnCase

  setup config do
    config
    |> Map.put(:contest, insert(:contest))
    |> login_if_needed
  end

  describe "index/2" do
    for role <- roles_except("local-organizer") do
      @tag login_as: role
      test "lists a contest's performances to #{role} users", %{conn: conn, contest: c} do
        conn = get(conn, internal_contest_performance_path(conn, :index, c))
        assert html_response(conn, 200) =~ "Performances"
      end
    end

    @tag login_as: "local-organizer"
    test "lists an own contest's performances to local organizers", %{conn: conn, user: u} do
      own_c = insert_own_contest(u)
      conn = get(conn, internal_contest_performance_path(conn, :index, own_c))
      assert html_response(conn, 200) =~ "Performances"
    end

    @tag login_as: "local-organizer"
    test "redirects local organizers when trying to list a foreign contest's performances", %{conn: conn, contest: c} do
      conn = get(conn, internal_contest_performance_path(conn, :index, c))
      assert_unauthorized_user(conn)
    end

    test "redirects guests when trying to list a contest's performances", %{conn: conn, contest: c} do
      conn = get(conn, internal_contest_performance_path(conn, :index, c))
      assert_unauthorized_guest(conn)
    end
  end

  describe "show/2" do
    for role <- roles_except("local-organizer") do
      @tag login_as: role
      test "shows a single performance to #{role} users", %{conn: conn, contest: c} do
        p = insert_performance(c)
        conn = get(conn, internal_contest_performance_path(conn, :show, c, p))
        assert html_response(conn, 200) =~ "Performance Details"
      end
    end

    @tag login_as: "local-organizer"
    test "shows a performance from an own contest to local organizers", %{conn: conn, user: u} do
      own_c = insert_own_contest(u)
      p = insert_performance(own_c)
      conn = get(conn, internal_contest_performance_path(conn, :show, own_c, p))
      assert html_response(conn, 200) =~ "Performance Details"
    end

    @tag login_as: "local-organizer"
    test "redirects local organizers when trying to view a performance from a foreign contest", %{conn: conn, contest: c} do
      p = insert_performance(c)
      conn = get(conn, internal_contest_performance_path(conn, :show, c, p))
      assert_unauthorized_user(conn)
    end

    test "redirects guests when trying to view a performance", %{conn: conn, contest: c} do
      p = insert_performance(c)
      conn = get(conn, internal_contest_performance_path(conn, :show, c, p))
      assert_unauthorized_guest(conn)
    end
  end

  # Private helpers

  defp insert_own_contest(user) do
    insert(:contest, host: insert(:host, users: [user]))
  end
end
