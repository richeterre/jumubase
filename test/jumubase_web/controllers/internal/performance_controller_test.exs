defmodule JumubaseWeb.Internal.PerformanceControllerTest do
  use JumubaseWeb.ConnCase
  alias Jumubase.JumuParams

  setup config do
    login_if_needed(config)
  end

  describe "for an admin" do
    @describetag login_as: "admin"

    test "lists a contest's performances", %{conn: conn} do
      contest = insert(:contest)
      conn = get(conn, internal_contest_performance_path(conn, :index, contest))
      assert html_response(conn, 200) =~ "Performances"
    end

    test "shows a single performance", %{conn: conn} do
      %{
        contest_category: %{contest: contest}
      } = performance = insert(:performance)
      conn = get(conn, internal_contest_performance_path(conn, :show, contest, performance))
      assert html_response(conn, 200) =~ "Performance Details"
    end
  end

  describe "for a non-admin" do
    for role <- List.delete(JumuParams.roles(), "admin") do
      @tag login_as: role
      test "(#{role}) redirects when trying to perform any action", %{conn: conn} do
        verify_all_routes(conn, &assert_unauthorized_user/1)
      end
    end
  end

  describe "for a guest" do
    test "redirects when trying to perform any action", %{conn: conn} do
      verify_all_routes(conn, &assert_unauthorized_guest/1)
    end
  end

  # Private helpers

  defp verify_all_routes(conn, assertion_fun) do
    Enum.each([
      get(conn, internal_contest_performance_path(conn, :index, 123)),
      get(conn, internal_contest_performance_path(conn, :show, 123, 456)),
    ], fn conn ->
      assertion_fun.(conn)
    end)
  end
end
