defmodule JumubaseWeb.Internal.ContestControllerTest do
  use JumubaseWeb.ConnCase
  alias Jumubase.JumuParams

  setup config do
    login_if_needed(config)
  end

  describe "for an admin" do
    @describetag login_as: "admin"

    test "lists all contests", %{conn: conn} do
      conn = get(conn, internal_contest_path(conn, :index))
      assert html_response(conn, 200) =~ "Contests"
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
      get(conn, internal_contest_path(conn, :index)),
    ], fn conn ->
      assertion_fun.(conn)
    end)
  end
end
