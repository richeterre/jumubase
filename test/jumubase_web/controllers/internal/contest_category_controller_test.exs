defmodule JumubaseWeb.Internal.ContestCategoryControllerTest do
  use JumubaseWeb.ConnCase

  setup config do
    config
    |> Map.put(:contest, insert(:contest))
    |> login_if_needed
  end

  describe "index/2" do
    for role <- roles_except("local-organizer") do
      @tag login_as: role
      test "lists a contest's categories to #{role} users", %{conn: conn, contest: c} do
        conn = get(conn, Routes.internal_contest_contest_category_path(conn, :index, c))
        assert html_response(conn, 200) =~ "Categories"
      end
    end

    @tag login_as: "local-organizer"
    test "lists an own contest's categories to local organizers", %{conn: conn, user: u} do
      own_c = insert_own_contest(u)
      conn = get(conn, Routes.internal_contest_contest_category_path(conn, :index, own_c))
      assert html_response(conn, 200) =~ "Categories"
    end

    @tag login_as: "local-organizer"
    test "redirects local organizers when trying to list a foreign contest's categories", %{conn: conn, contest: c} do
      conn = get(conn, Routes.internal_contest_contest_category_path(conn, :index, c))
      assert_unauthorized_user(conn)
    end

    test "redirects guests when trying to list a contest's categories", %{conn: conn, contest: c} do
      conn = get(conn, Routes.internal_contest_contest_category_path(conn, :index, c))
      assert_unauthorized_guest(conn)
    end
  end

  # Private helpers

  defp insert_own_contest(user) do
    insert(:contest, host: insert(:host, users: [user]))
  end
end
