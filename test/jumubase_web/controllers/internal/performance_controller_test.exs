defmodule JumubaseWeb.Internal.PerformanceControllerTest do
  use JumubaseWeb.ConnCase
  alias Jumubase.Repo
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
        conn = get(conn, Routes.internal_contest_performance_path(conn, :index, c))
        assert html_response(conn, 200) =~ "Performances"
      end
    end

    @tag login_as: "local-organizer"
    test "lists an own contest's performances to local organizers", %{conn: conn, user: u} do
      own_c = insert_own_contest(u)
      conn = get(conn, Routes.internal_contest_performance_path(conn, :index, own_c))
      assert html_response(conn, 200) =~ "Performances"
    end

    @tag login_as: "local-organizer"
    test "redirects local organizers when trying to list a foreign contest's performances", %{conn: conn, contest: c} do
      conn = get(conn, Routes.internal_contest_performance_path(conn, :index, c))
      assert_unauthorized_user(conn)
    end

    test "redirects guests when trying to list a contest's performances", %{conn: conn, contest: c} do
      conn = get(conn, Routes.internal_contest_performance_path(conn, :index, c))
      assert_unauthorized_guest(conn)
    end
  end

  describe "show/2" do
    for role <- roles_except("local-organizer") do
      @tag login_as: role
      test "shows a single performance to #{role} users", %{conn: conn, contest: c} do
        p = insert_performance(c)
        conn = get(conn, Routes.internal_contest_performance_path(conn, :show, c, p))
        assert html_response(conn, 200) =~ p.edit_code
      end
    end

    @tag login_as: "local-organizer"
    test "shows a performance from an own contest to local organizers", %{conn: conn, user: u} do
      own_c = insert_own_contest(u)
      p = insert_performance(own_c)
      conn = get(conn, Routes.internal_contest_performance_path(conn, :show, own_c, p))
      assert html_response(conn, 200) =~ p.edit_code
    end

    @tag login_as: "local-organizer"
    test "redirects local organizers when trying to view a performance from a foreign contest", %{conn: conn, contest: c} do
      p = insert_performance(c)
      conn = get(conn, Routes.internal_contest_performance_path(conn, :show, c, p))
      assert_unauthorized_user(conn)
    end

    test "redirects guests when trying to view a performance", %{conn: conn, contest: c} do
      p = insert_performance(c)
      conn = get(conn, Routes.internal_contest_performance_path(conn, :show, c, p))
      assert_unauthorized_guest(conn)
    end
  end

  describe "new/2" do
    for role <- roles_except("local-organizer") do
      @tag login_as: role
      test "lets #{role} users fill in a new performance", %{conn: conn, contest: c} do
        conn = conn |> attempt_new(c)
        assert html_response(conn, 200) =~ "New Performance"
      end
    end

    @tag login_as: "local-organizer"
    test "lets local organizers fill in a new performance for an own contest", %{conn: conn, user: u} do
      own_c = insert_own_contest(u)
      conn = conn |> attempt_new(own_c)
      assert html_response(conn, 200) =~ "New Performance"
    end

    @tag login_as: "local-organizer"
    test "redirects local organizers when trying to fill in a new performance for a foreign contest", %{conn: conn, contest: c} do
      conn = conn |> attempt_new(c)
      assert_unauthorized_user(conn)
    end

    test "redirects guests when trying to fill in a new performance", %{conn: conn, contest: c} do
      conn = conn |> attempt_new(c)
      assert_unauthorized_guest(conn)
    end
  end

  describe "create/2" do
    setup %{contest: c} do
      [contest: c |> with_contest_categories]
    end

    for role <- roles_except("local-organizer") do
      @tag login_as: role
      test "lets #{role} users create a performance", %{conn: conn, contest: c} do
        conn
        |> attempt_create(c)
        |> assert_create_success(c, Repo.one(Performance))
      end
    end

    @tag login_as: "local-organizer"
    test "lets local organizers create a performance from an own contest", %{conn: conn, user: u} do
      own_c = insert_own_contest(u) |> with_contest_categories
      conn
      |> attempt_create(own_c)
      |> assert_create_success(own_c, Repo.one(Performance))
    end

    @tag login_as: "local-organizer"
    test "redirects local organizers when trying to create a performance from a foreign contest", %{conn: conn, contest: c} do
      conn |> attempt_create(c) |> assert_unauthorized_user
    end

    test "redirects guests when trying to create a performance", %{conn: conn, contest: c} do
      conn |> attempt_create(c) |> assert_unauthorized_guest
    end
  end

  describe "edit/2" do
    setup %{contest: c} do
      [performance: insert_performance(c)]
    end

    for role <- roles_except("local-organizer") do
      @tag login_as: role
      test "lets #{role} users edit a performance", %{conn: conn, contest: c, performance: p} do
        conn = get(conn, Routes.internal_contest_performance_path(conn, :edit, c, p))
        assert html_response(conn, 200) =~ "Edit performance"
      end
    end

    @tag login_as: "local-organizer"
    test "lets local organizers edit a performance from an own contest", %{conn: conn, user: u} do
      own_c = insert_own_contest(u)
      p = insert_performance(own_c)
      conn = get(conn, Routes.internal_contest_performance_path(conn, :edit, own_c, p))
      assert html_response(conn, 200) =~ "Edit performance"
    end

    @tag login_as: "local-organizer"
    test "redirects local organizers when trying to edit a performance from a foreign contest", %{conn: conn, contest: c, performance: p} do
      conn = get(conn, Routes.internal_contest_performance_path(conn, :edit, c, p))
      assert_unauthorized_user(conn)
    end

    test "redirects guests when trying to edit a performance", %{conn: conn, contest: c, performance: p} do
      conn = get(conn, Routes.internal_contest_performance_path(conn, :edit, c, p))
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

        conn = put(conn, Routes.internal_contest_performance_path(conn, :update, c, p), params)
        assert_update_success(conn, c, p)
      end
    end

    @tag login_as: "local-organizer"
    test "lets local organizers update a performance from an own contest", %{conn: conn, user: u} do
      own_c = insert_own_contest(u) |> with_contest_categories
      [cc1, cc2] = own_c.contest_categories
      p = insert_performance(cc1)
      params = valid_performance_params(cc2)

      conn = put(conn, Routes.internal_contest_performance_path(conn, :update, own_c, p), params)
      assert_update_success(conn, own_c, p)
    end

    @tag login_as: "local-organizer"
    test "redirects local organizers when trying to update a performance from a foreign contest", %{conn: conn, contest: c, performance: p} do
      [_cc1, cc2] = c.contest_categories
      params = valid_performance_params(cc2)

      conn = put(conn, Routes.internal_contest_performance_path(conn, :update, c, p), params)
      assert_unauthorized_user(conn)
    end

    test "redirects guests when trying to update a performance", %{conn: conn, contest: c, performance: p} do
      [_cc1, cc2] = c.contest_categories
      params = valid_performance_params(cc2)

      conn = put(conn, Routes.internal_contest_performance_path(conn, :update, c, p), params)
      assert_unauthorized_guest(conn)
    end
  end

  describe "delete/2" do
    for role <- roles_except("local-organizer") do
      @tag login_as: role
      test "lets #{role} users delete a performance", %{conn: conn, contest: c} do
        p = insert_performance(c)
        conn = delete(conn, Routes.internal_contest_performance_path(conn, :delete, c, p))
        assert_deletion_success(conn, c)
      end
    end

    @tag login_as: "local-organizer"
    test "lets local organizers delete a performance from an own contest", %{conn: conn, user: u} do
      own_c = insert_own_contest(u)
      p = insert_performance(own_c)
      conn = delete(conn, Routes.internal_contest_performance_path(conn, :delete, own_c, p))
      assert_deletion_success(conn, own_c)
    end

    @tag login_as: "local-organizer"
    test "redirects local organizers when trying to delete a performance from a foreign contest", %{conn: conn, contest: c} do
      p = insert_performance(c)
      conn = get(conn, Routes.internal_contest_performance_path(conn, :delete, c, p))
      assert_unauthorized_user(conn)
    end

    test "redirects guests when trying to delete a performance", %{conn: conn, contest: c} do
      p = insert_performance(c)
      conn = get(conn, Routes.internal_contest_performance_path(conn, :delete, c, p))
      assert_unauthorized_guest(conn)
    end
  end

  describe "reschedule/2" do
    setup %{contest: c} do
      [contest: c]
    end

    for role <- roles_except("local-organizer") do
      @tag login_as: role
      test "lets #{role} users reschedule performances", %{conn: conn, contest: c} do
        params = get_reschedule_params(c)
        conn = patch(conn, Routes.internal_contest_performance_path(conn, :reschedule, c), params)
        assert text_response(conn, 200) == "Success"
      end
    end

    @tag login_as: "local-organizer"
    test "lets local organizers reschedule performances from an own contest", %{conn: conn, user: u} do
      own_c = insert_own_contest(u)
      params = get_reschedule_params(own_c)
      conn = patch(conn, Routes.internal_contest_performance_path(conn, :reschedule, own_c), params)
      assert text_response(conn, 200) == "Success"
    end

    @tag login_as: "local-organizer"
    test "redirects local organizers when trying to reschedule performances from a foreign contest", %{conn: conn, contest: c} do
      params = get_reschedule_params(c)
      conn = patch(conn, Routes.internal_contest_performance_path(conn, :reschedule, c), params)
      assert_unauthorized_user(conn)
    end

    test "redirects guests when trying to reschedule performances", %{conn: conn, contest: c} do
      params = get_reschedule_params(c)
      conn = patch(conn, Routes.internal_contest_performance_path(conn, :reschedule, c), params)
      assert_unauthorized_guest(conn)
    end

    @tag login_as: "admin"
    test "returns an error for invalid reschedule params", %{conn: conn, contest: c} do
      p = insert_performance(c)
      params = %{"performances" => %{
        p.id => %{"stageId" => nil, "stageTime" => "2019-01-01T07:00:00Z"}}
      }
      conn = patch(conn, Routes.internal_contest_performance_path(conn, :reschedule, c), params)
      assert text_response(conn, 422) == "Error"
    end
  end

  # Private helpers

  defp insert_own_contest(user) do
    insert(:contest, host: insert(:host, users: [user]))
  end

  defp get_reschedule_params(contest) do
    stage_time_1 = "2019-01-01T07:00:00Z"
    stage_time_2 = "2019-01-02T07:00:00Z"

    [s1, s2] = insert_list(2, :stage)
    p1 = insert_performance(contest, stage: nil, stage_time: nil)
    p2 = insert_performance(contest, stage: s1, stage_time: stage_time_1)
    p3 = insert_performance(contest, stage: s2, stage_time: stage_time_2)

    %{"performances" => %{
      p1.id => %{"stageId" => s1.id, "stageTime" => stage_time_1},
      p2.id => %{"stageId" => s2.id, "stageTime" => stage_time_2},
      p3.id => %{"stageId" => nil, "stageTime" => nil},
    }}
  end

  defp attempt_new(conn, contest) do
    get(conn, Routes.internal_contest_performance_path(conn, :new, contest))
  end

  defp attempt_create(conn, contest) do
    [cc, _] = contest.contest_categories
    params = valid_performance_params(cc)
    post(conn, Routes.internal_contest_performance_path(conn, :create, contest), params)
  end

  defp assert_create_success(conn, contest, performance) do
    assert_success(conn,
      Routes.internal_contest_performance_path(conn, :show, contest, performance),
      "The performance was created."
    )
  end

  defp assert_update_success(conn, contest, performance) do
    assert_success(conn,
      Routes.internal_contest_performance_path(conn, :show, contest, performance),
      "The performance was updated."
    )
  end

  defp assert_deletion_success(conn, contest) do
    assert_success(conn,
      Routes.internal_contest_performance_path(conn, :index, contest),
      "The performance was deleted."
    )
  end

  defp assert_success(conn, redirect_path, message) do
    assert redirected_to(conn) == redirect_path
    conn = get(recycle(conn), redirect_path) # Follow redirection
    assert html_response(conn, 200) =~ message
  end
end
