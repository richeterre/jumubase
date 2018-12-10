defmodule JumubaseWeb.Internal.PerformanceControllerTest do
  use JumubaseWeb.ConnCase
  alias Jumubase.Showtime.Performance

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
        assert html_response(conn, 200) =~ p.edit_code
      end
    end

    @tag login_as: "local-organizer"
    test "shows a performance from an own contest to local organizers", %{conn: conn, user: u} do
      own_c = insert_own_contest(u)
      p = insert_performance(own_c)
      conn = get(conn, internal_contest_performance_path(conn, :show, own_c, p))
      assert html_response(conn, 200) =~ p.edit_code
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

  describe "edit/2" do
    setup %{contest: c} do
      [performance: insert_performance(c)]
    end

    for role <- roles_except("local-organizer") do
      @tag login_as: role
      test "lets #{role} users edit a performance", %{conn: conn, contest: c, performance: p} do
        conn = get(conn, internal_contest_performance_path(conn, :edit, c, p))
        assert html_response(conn, 200) =~ "Edit performance"
      end
    end

    @tag login_as: "local-organizer"
    test "lets local organizers edit a performance from an own contest", %{conn: conn, user: u} do
      own_c = insert_own_contest(u)
      p = insert_performance(own_c)
      conn = get(conn, internal_contest_performance_path(conn, :edit, own_c, p))
      assert html_response(conn, 200) =~ "Edit performance"
    end

    @tag login_as: "local-organizer"
    test "redirects local organizers when trying to edit a performance from a foreign contest", %{conn: conn, contest: c, performance: p} do
      conn = get(conn, internal_contest_performance_path(conn, :edit, c, p))
      assert_unauthorized_user(conn)
    end

    test "redirects guests when trying to edit a performance", %{conn: conn, contest: c, performance: p} do
      conn = get(conn, internal_contest_performance_path(conn, :edit, c, p))
      assert_unauthorized_guest(conn)
    end
  end

  describe "update/2" do
    setup %{contest: c} do
      c = c |> with_contest_categories
      [cc1, _cc2] = c.contest_categories
      [contest: c, performance: insert_performance(cc1)]
    end

    for role <- roles_except("local-organizer") do
      @tag login_as: role
      test "lets #{role} users update a performance", %{conn: conn, contest: c, performance: p} do
        [_cc1, cc2] = c.contest_categories
        params = valid_performance_params(cc2)

        conn = put(conn, internal_contest_performance_path(conn, :update, c, p), params)
        assert_update_success(conn, c, p)
      end
    end

    @tag login_as: "local-organizer"
    test "lets local organizers update a performance from an own contest", %{conn: conn, user: u} do
      own_c = insert_own_contest(u) |> with_contest_categories
      [cc1, cc2] = own_c.contest_categories
      p = insert_performance(cc1)
      params = valid_performance_params(cc2)

      conn = put(conn, internal_contest_performance_path(conn, :update, own_c, p), params)
      assert_update_success(conn, own_c, p)
    end

    @tag login_as: "local-organizer"
    test "redirects local organizers when trying to update a performance from a foreign contest", %{conn: conn, contest: c, performance: p} do
      [_cc1, cc2] = c.contest_categories
      params = valid_performance_params(cc2)

      conn = put(conn, internal_contest_performance_path(conn, :update, c, p), params)
      assert_unauthorized_user(conn)
    end

    test "redirects guests when trying to update a performance", %{conn: conn, contest: c, performance: p} do
      [_cc1, cc2] = c.contest_categories
      params = valid_performance_params(cc2)

      conn = put(conn, internal_contest_performance_path(conn, :update, c, p), params)
      assert_unauthorized_guest(conn)
    end
  end

  describe "delete/2" do
    for role <- roles_except("local-organizer") do
      @tag login_as: role
      test "lets #{role} users delete a performance", %{conn: conn, contest: c} do
        p = insert_performance(c)
        conn = delete(conn, internal_contest_performance_path(conn, :delete, c, p))
        assert_deletion_success(conn, c, p)
      end
    end

    @tag login_as: "local-organizer"
    test "lets local organizers delete a performance from an own contest", %{conn: conn, user: u} do
      own_c = insert_own_contest(u)
      p = insert_performance(own_c)
      conn = delete(conn, internal_contest_performance_path(conn, :delete, own_c, p))
      assert_deletion_success(conn, own_c, p)
    end

    @tag login_as: "local-organizer"
    test "redirects local organizers when trying to delete a performance from a foreign contest", %{conn: conn, contest: c} do
      p = insert_performance(c)
      conn = get(conn, internal_contest_performance_path(conn, :delete, c, p))
      assert_unauthorized_user(conn)
    end

    test "redirects guests when trying to delete a performance", %{conn: conn, contest: c} do
      p = insert_performance(c)
      conn = get(conn, internal_contest_performance_path(conn, :delete, c, p))
      assert_unauthorized_guest(conn)
    end
  end

  # Private helpers

  defp insert_own_contest(user) do
    insert(:contest, host: insert(:host, users: [user]))
  end

  defp assert_update_success(conn, contest, %Performance{edit_code: ec}) do
    assert_success(conn, contest, "The performance with edit code #{ec} was updated.")
  end

  defp assert_deletion_success(conn, contest, %Performance{edit_code: ec}) do
    assert_success(conn, contest, "The performance with edit code #{ec} was deleted.")
  end

  defp assert_success(conn, contest, message) do
    redirect_path = internal_contest_performance_path(conn, :index, contest)

    assert redirected_to(conn) == redirect_path
    conn = get(recycle(conn), redirect_path) # Follow redirection
    assert html_response(conn, 200) =~ message
  end
end
