defmodule JumubaseWeb.Internal.ContestCategoryControllerTest do
  use JumubaseWeb.ConnCase

  setup config do
    config
    |> Map.put(:contest, insert(:contest))
    |> login_if_needed
  end

  describe "index/2" do
    for role <- all_roles() do
      @tag login_as: role
      test "lists a contest's categories to authorized #{role} users", %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        conn = get(conn, Routes.internal_contest_contest_category_path(conn, :index, c))
        assert html_response(conn, 200) =~ "Categories"
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to list a contest's categories",
           %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u)
        conn = get(conn, Routes.internal_contest_contest_category_path(conn, :index, c))
        assert_unauthorized_user(conn)
      end
    end

    test "redirects guests trying to list a contest's categories", %{conn: conn, contest: c} do
      conn = get(conn, Routes.internal_contest_contest_category_path(conn, :index, c))
      assert_unauthorized_guest(conn)
    end
  end
end
