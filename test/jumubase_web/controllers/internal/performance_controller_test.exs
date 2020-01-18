defmodule JumubaseWeb.Internal.PerformanceControllerTest do
  use JumubaseWeb.ConnCase
  alias Jumubase.Repo
  alias Jumubase.Foundation.Contest
  alias Jumubase.Showtime.Performance

  setup config do
    config
    |> Map.put(:contest, insert(:contest))
    |> login_if_needed
  end

  describe "index/2" do
    for role <- all_roles() do
      @tag login_as: role
      test "lists contest performances to authorized #{role} users", %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        conn = get(conn, Routes.internal_contest_performance_path(conn, :index, c))
        assert html_response(conn, 200) =~ "Performances"
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to list contest performances",
           %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u)
        conn = get(conn, Routes.internal_contest_performance_path(conn, :index, c))
        assert_unauthorized_user(conn)
      end
    end

    test "redirects guests trying to list contest performances", %{conn: conn, contest: c} do
      conn = get(conn, Routes.internal_contest_performance_path(conn, :index, c))
      assert_unauthorized_guest(conn)
    end
  end

  describe "show/2" do
    for role <- all_roles() do
      @tag login_as: role
      test "shows a single performance to authorized #{role} users", %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        p = insert_performance(c)
        conn = get(conn, Routes.internal_contest_performance_path(conn, :show, c, p))
        assert html_response(conn, 200) =~ p.edit_code
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to view a performance",
           %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u)
        p = insert_performance(c)
        conn = get(conn, Routes.internal_contest_performance_path(conn, :show, c, p))
        assert_unauthorized_user(conn)
      end
    end

    test "redirects guests trying to view a performance", %{conn: conn, contest: c} do
      p = insert_performance(c)
      conn = get(conn, Routes.internal_contest_performance_path(conn, :show, c, p))
      assert_unauthorized_guest(conn)
    end
  end

  describe "new/2" do
    for role <- all_roles() do
      @tag login_as: role
      test "lets authorized #{role} users fill in a new performance", %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        conn = conn |> attempt_new(c)
        assert html_response(conn, 200) =~ "New Performance"
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to fill in a new performance",
           %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u)
        conn |> attempt_new(c) |> assert_unauthorized_user
      end
    end

    test "redirects guests trying to fill in a new performance", %{conn: conn, contest: c} do
      conn |> attempt_new(c) |> assert_unauthorized_guest
    end
  end

  describe "create/2" do
    for role <- roles_except("observer") do
      @tag login_as: role
      test "lets authorized #{role} users create a performance", %{conn: conn, user: u} do
        c = insert_authorized_contest(u) |> with_contest_categories

        conn
        |> attempt_create(c)
        |> assert_create_success(c, Repo.one(Performance))
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to create a performance",
           %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u) |> with_contest_categories
        conn |> attempt_create(c) |> assert_unauthorized_user
      end
    end

    @tag login_as: "observer"
    test "redirects observers trying to create a performance", %{conn: conn, contest: c} do
      c = c |> with_contest_categories
      conn |> attempt_create(c) |> assert_unauthorized_user
    end

    test "redirects guests trying to create a performance", %{conn: conn, contest: c} do
      c = c |> with_contest_categories
      conn |> attempt_create(c) |> assert_unauthorized_guest
    end
  end

  describe "edit/2" do
    for role <- all_roles() do
      @tag login_as: role
      test "lets authorized #{role} users edit a performance", %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        p = insert_performance(c)
        conn = get(conn, Routes.internal_contest_performance_path(conn, :edit, c, p))
        assert html_response(conn, 200) =~ "Edit performance"
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} organizers trying to edit a performance",
           %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u)
        p = insert_performance(c)
        conn = get(conn, Routes.internal_contest_performance_path(conn, :edit, c, p))
        assert_unauthorized_user(conn)
      end
    end

    test "redirects guests trying to edit a performance", %{conn: conn, contest: c} do
      p = insert_performance(c)
      conn = get(conn, Routes.internal_contest_performance_path(conn, :edit, c, p))
      assert_unauthorized_guest(conn)
    end

    for role <- all_roles() do
      @tag login_as: role
      test "redirects authorized #{role} users if the performance has results",
           %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        p = insert_performance(c, appearances: [build(:appearance, points: 1)])

        conn
        |> get(Routes.internal_contest_performance_path(conn, :edit, c, p))
        |> assert_flash_redirect(
          Routes.internal_contest_performance_path(conn, :index, c),
          "This performance already has results. To edit it, please clear them first."
        )
      end
    end
  end

  describe "update/2" do
    setup %{contest: c} do
      c = c |> with_contest_categories
      [cc1, _cc2] = c.contest_categories
      [contest: c, performance: insert_performance(cc1)]
    end

    for role <- roles_except("observer") do
      @tag login_as: role
      test "lets authorized #{role} users update a performance", %{conn: conn, user: u} do
        c = insert_authorized_contest(u) |> with_contest_categories()
        p = insert_performance(c)
        conn |> attempt_update(c, p) |> assert_update_success(c, p)
      end

      @tag login_as: role
      test "redirects authorized #{role} users if the performance has results",
           %{conn: conn, user: u} do
        c = insert_authorized_contest(u) |> with_contest_categories()
        p = insert_performance(c, appearances: [build(:appearance, points: 1)])

        conn
        |> attempt_update(c, p)
        |> assert_flash_redirect(
          Routes.internal_contest_performance_path(conn, :index, c),
          "This performance already has results. To edit it, please clear them first."
        )
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to update a performance",
           %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u) |> with_contest_categories()
        p = insert_performance(c)
        conn |> attempt_update(c, p) |> assert_unauthorized_user
      end
    end

    @tag login_as: "observer"
    test "redirects observers trying to update a performance", %{
      conn: conn,
      contest: c,
      performance: p
    } do
      conn |> attempt_update(c, p) |> assert_unauthorized_user
    end

    test "redirects guests trying to update a performance", %{
      conn: conn,
      contest: c,
      performance: p
    } do
      conn |> attempt_update(c, p) |> assert_unauthorized_guest
    end
  end

  describe "delete/2" do
    for role <- roles_except("observer") do
      @tag login_as: role
      test "lets authorized #{role} users delete a performance", %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        conn |> attempt_delete(c) |> assert_deletion_success(c)
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to delete a performance",
           %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u)
        conn |> attempt_delete(c) |> assert_unauthorized_user
      end
    end

    @tag login_as: "observer"
    test "redirects observers trying to delete a performance", %{conn: conn, contest: c} do
      conn |> attempt_delete(c) |> assert_unauthorized_user
    end

    test "redirects guests trying to delete a performance", %{conn: conn, contest: c} do
      conn |> attempt_delete(c) |> assert_unauthorized_guest
    end
  end

  describe "reschedule/2" do
    for role <- roles_except("observer") do
      @tag login_as: role
      test "lets authorized #{role} users reschedule performances", %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        test_reschedule_success(conn, c)
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to reschedule performances",
           %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u)
        conn |> attempt_reschedule(c) |> assert_unauthorized_user
      end
    end

    @tag login_as: "observer"
    test "redirects observers trying to reschedule performances", %{conn: conn, contest: c} do
      conn |> attempt_reschedule(c) |> assert_unauthorized_user
    end

    test "redirects guests trying to reschedule performances", %{conn: conn, contest: c} do
      conn |> attempt_reschedule(c) |> assert_unauthorized_guest
    end

    @tag login_as: "admin"
    test "returns an error for invalid reschedule params", %{conn: conn, contest: c} do
      p = insert_performance(c)

      params = %{
        "performances" => %{p.id => %{"stageId" => nil, "stageTime" => "2019-01-01T07:00:00"}}
      }

      conn = patch(conn, Routes.internal_contest_performance_path(conn, :reschedule, c), params)

      assert json_response(conn, 422) == %{
               "error" => %{
                 "performanceId" => to_string(p.id),
                 "errors" => %{
                   "base" => [
                     "The performance can either have both stage and stage time, or neither."
                   ]
                 }
               }
             }
    end
  end

  describe "jury_material/2" do
    for role <- all_roles() do
      @tag login_as: role
      test "lets authorized #{role} users list a contest's performances to create jury material",
           %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        conn |> attempt_jury_material(c) |> assert_jury_material_success
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to list a contest's performances to create jury material",
           %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u)
        conn |> attempt_jury_material(c) |> assert_unauthorized_user
      end
    end

    test "redirects guests trying to list a contest's performances to create jury material",
         %{conn: conn, contest: c} do
      conn |> attempt_jury_material(c) |> assert_unauthorized_guest
    end
  end

  describe "print_jury_sheets/2" do
    for role <- all_roles() do
      @tag login_as: role
      test "lets authorized #{role} users print jury sheets",
           %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        conn |> attempt_print_jury_sheets(c) |> assert_pdf_response
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to print jury sheets",
           %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u)
        conn |> attempt_print_jury_sheets(c) |> assert_unauthorized_user
      end
    end

    test "redirects guests trying to print jury sheets", %{
      conn: conn,
      contest: c
    } do
      conn |> attempt_print_jury_sheets(c) |> assert_unauthorized_guest
    end
  end

  describe "print_jury_table/2" do
    for role <- all_roles() do
      @tag login_as: role
      test "lets authorized #{role} users print a jury table",
           %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        conn |> attempt_print_jury_table(c) |> assert_pdf_response
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to print a jury table",
           %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u)
        conn |> attempt_print_jury_table(c) |> assert_unauthorized_user
      end
    end

    test "redirects guests trying to print a jury table", %{
      conn: conn,
      contest: c
    } do
      conn |> attempt_print_jury_table(c) |> assert_unauthorized_guest
    end
  end

  describe "edit_results/2" do
    for role <- all_roles() do
      @tag login_as: role
      test "lets authorized #{role} users edit results", %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        conn |> attempt_edit_results(c) |> assert_results_success
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to edit results", %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u)
        conn |> attempt_edit_results(c) |> assert_unauthorized_user
      end
    end

    test "redirects guests trying to edit results", %{conn: conn, contest: c} do
      conn |> attempt_edit_results(c) |> assert_unauthorized_guest
    end
  end

  describe "update_results/2" do
    for role <- roles_except("observer") do
      @tag login_as: role
      test "lets authorized #{role} users update results", %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        conn |> attempt_update_results(c) |> assert_update_results_success(c)
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to update results", %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u)
        conn |> attempt_update_results(c) |> assert_unauthorized_user
      end
    end

    @tag login_as: "observer"
    test "redirects observers trying to update results", %{conn: conn, contest: c} do
      conn |> attempt_update_results(c) |> assert_unauthorized_user
    end

    test "redirects guests trying to update results", %{conn: conn, contest: c} do
      conn |> attempt_update_results(c) |> assert_unauthorized_guest
    end

    @tag login_as: "admin"
    test "handles updating results with an empty appearance id array", %{conn: conn, contest: c} do
      params = %{"results" => %{"appearance_ids" => "", "points" => "25"}}
      patch(conn, Routes.internal_contest_results_path(conn, :update_results, c), params)
    end
  end

  describe "publish_results/2" do
    for role <- all_roles() do
      @tag login_as: role
      test "lets authorized #{role} users list a contest's performances for result publishing",
           %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        conn |> attempt_publish_results(c) |> assert_publish_results_success
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to list a contest's performances for result publishing",
           %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u)
        conn |> attempt_publish_results(c) |> assert_unauthorized_user
      end
    end

    test "redirects guests trying to list a contest's performances for result publishing",
         %{conn: conn, contest: c} do
      conn |> attempt_publish_results(c) |> assert_unauthorized_guest
    end
  end

  describe "update_results_public/2" do
    for role <- roles_except("observer") do
      @tag login_as: role
      test "lets authorized #{role} users publish a contest's performance results",
           %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        conn |> attempt_update_results_public(c) |> assert_update_results_public_success(c)
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to publish a contest's performance results",
           %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u)
        conn |> attempt_update_results_public(c) |> assert_unauthorized_user
      end
    end

    @tag login_as: "observer"
    test "redirects observers trying to publish a contest's performance results",
         %{conn: conn, contest: c} do
      conn |> attempt_update_results_public(c) |> assert_unauthorized_user
    end

    test "redirects guests trying to publish a contest's performance results", %{
      conn: conn,
      contest: c
    } do
      conn |> attempt_update_results_public(c) |> assert_unauthorized_guest
    end
  end

  describe "certificates/2" do
    for role <- all_roles() do
      @tag login_as: role
      test "lets authorized #{role} users list a contest's performances to create certificates",
           %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        conn |> attempt_certificates(c) |> assert_certificates_success
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to list a contest's performances to create certificates",
           %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u)
        conn |> attempt_certificates(c) |> assert_unauthorized_user
      end
    end

    test "redirects guests trying to list a contest's performances to create certificates",
         %{conn: conn, contest: c} do
      conn |> attempt_certificates(c) |> assert_unauthorized_guest
    end
  end

  describe "print_certificates/2" do
    for role <- all_roles() do
      @tag login_as: role
      test "lets authorized #{role} users print certificates",
           %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        conn |> attempt_print_certificates(c) |> assert_pdf_response
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to print certificates",
           %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u)
        conn |> attempt_print_certificates(c) |> assert_unauthorized_user
      end
    end

    test "redirects guests trying to print certificates", %{conn: conn, contest: c} do
      conn |> attempt_print_certificates(c) |> assert_unauthorized_guest
    end
  end

  describe "advancing/2" do
    for role <- all_roles() do
      @tag login_as: role
      test "lets authorized #{role} users list a contest's advancing performances",
           %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        conn |> attempt_advancing(c) |> assert_advancing_success
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to list a contest's advancing performances",
           %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u)
        conn |> attempt_advancing(c) |> assert_unauthorized_user
      end
    end

    test "redirects guests trying to list a contest's advancing performances",
         %{conn: conn, contest: c} do
      conn |> attempt_advancing(c) |> assert_unauthorized_guest
    end
  end

  describe "migrate_advancing/2" do
    @tag login_as: "admin"
    test "lets admins migrate advancing performances", %{conn: conn, contest: c} do
      conn |> attempt_migrate_advancing(c) |> assert_migrate_advancing_success(c)
    end

    for role <- roles_except("admin") do
      @tag login_as: role
      test "redirects #{role} users trying to migrate advancing performances",
           %{conn: conn, contest: c} do
        conn |> attempt_migrate_advancing(c) |> assert_unauthorized_user
      end
    end

    test "redirects guests trying to migrate advancing performances", %{conn: conn, contest: c} do
      conn |> attempt_migrate_advancing(c) |> assert_unauthorized_guest
    end
  end

  # Private helpers

  defp attempt_new(conn, contest) do
    get(conn, Routes.internal_contest_performance_path(conn, :new, contest))
  end

  defp attempt_create(conn, contest) do
    [cc, _] = contest.contest_categories
    params = valid_performance_params(cc)
    post(conn, Routes.internal_contest_performance_path(conn, :create, contest), params)
  end

  defp attempt_update(conn, c, p) do
    [_cc1, cc2] = c.contest_categories
    params = valid_performance_params(cc2)
    put(conn, Routes.internal_contest_performance_path(conn, :update, c, p), params)
  end

  defp attempt_delete(conn, c) do
    p = insert_performance(c)
    delete(conn, Routes.internal_contest_performance_path(conn, :delete, c, p))
  end

  defp attempt_reschedule(conn, contest) do
    p = insert_performance(contest, stage: build(:stage), stage_time: Timex.now())
    params = %{"performances" => %{p.id => %{"stageId" => nil, "stageTime" => nil}}}
    conn |> patch(Routes.internal_contest_performance_path(conn, :reschedule, contest), params)
  end

  defp attempt_jury_material(conn, contest) do
    get(conn, Routes.internal_contest_performances_path(conn, :jury_material, contest))
  end

  defp attempt_print_jury_sheets(conn, contest) do
    p1 = insert_performance(contest)
    p2 = insert_performance(contest)

    get(
      conn,
      Routes.internal_contest_performance_path(conn, :print_jury_sheets, contest,
        performance_ids: [p1.id, p2.id]
      )
    )
  end

  defp attempt_print_jury_table(conn, contest) do
    p1 = insert_performance(contest)
    p2 = insert_performance(contest)

    get(
      conn,
      Routes.internal_contest_performance_path(conn, :print_jury_table, contest,
        performance_ids: [p1.id, p2.id]
      )
    )
  end

  defp attempt_edit_results(conn, contest) do
    get(conn, Routes.internal_contest_results_path(conn, :edit_results, contest))
  end

  defp attempt_update_results(conn, contest) do
    a1 = insert_appearance(contest)
    a2 = insert_appearance(contest)
    params = %{"results" => %{"appearance_ids" => "#{a1.id},#{a2.id}", "points" => "25"}}
    conn |> patch(Routes.internal_contest_results_path(conn, :update_results, contest), params)
  end

  defp attempt_publish_results(conn, contest) do
    conn |> get(Routes.internal_contest_results_path(conn, :publish_results, contest))
  end

  defp attempt_update_results_public(conn, contest) do
    p1 = insert_performance(contest)
    p2 = insert_performance(contest)
    params = %{"performance_ids" => [p1.id, p2.id], "public" => true}

    conn
    |> patch(Routes.internal_contest_results_path(conn, :update_results_public, contest), params)
  end

  defp attempt_certificates(conn, contest) do
    get(conn, Routes.internal_contest_performances_path(conn, :certificates, contest))
  end

  defp attempt_print_certificates(conn, contest) do
    p1 = insert_performance(contest)
    p2 = insert_performance(contest)

    get(
      conn,
      Routes.internal_contest_performance_path(conn, :print_certificates, contest,
        performance_ids: [p1.id, p2.id]
      )
    )
  end

  defp attempt_advancing(conn, contest) do
    get(conn, Routes.internal_contest_performances_path(conn, :advancing, contest))
  end

  defp attempt_migrate_advancing(conn, %Contest{round: 1} = rw) do
    lw = insert(:contest, season: rw.season, round: 2)
    cg = insert(:category)
    rw_cc = insert(:contest_category, contest: rw, category: cg)
    insert(:contest_category, contest: lw, category: cg)

    p1 = insert_performance(rw_cc)
    p2 = insert_performance(rw_cc)

    post(
      conn,
      Routes.internal_contest_performances_path(conn, :migrate_advancing, rw,
        performance_ids: [p1.id, p2.id]
      )
    )
  end

  defp assert_create_success(conn, contest, performance) do
    assert_flash_redirect(
      conn,
      Routes.internal_contest_performance_path(conn, :show, contest, performance),
      "The performance was created."
    )
  end

  defp assert_update_success(conn, contest, performance) do
    assert_flash_redirect(
      conn,
      Routes.internal_contest_performance_path(conn, :show, contest, performance),
      "The performance was updated."
    )
  end

  defp assert_deletion_success(conn, contest) do
    assert_flash_redirect(
      conn,
      Routes.internal_contest_performance_path(conn, :index, contest),
      "The performance was deleted."
    )
  end

  defp assert_jury_material_success(conn) do
    assert html_response(conn, 200) =~ "Create jury material"
  end

  defp assert_pdf_response(conn) do
    assert response_content_type(conn, :pdf) =~ "charset=utf-8"
  end

  defp assert_results_success(conn) do
    assert html_response(conn, 200) =~ "Enter points"
  end

  defp assert_update_results_success(conn, contest) do
    assert redirected_to(conn) ==
             Routes.internal_contest_results_path(conn, :edit_results, contest)
  end

  defp assert_publish_results_success(conn) do
    assert html_response(conn, 200) =~ "Publish results"
  end

  defp assert_update_results_public_success(conn, contest) do
    assert_flash_redirect(
      conn,
      Routes.internal_contest_results_path(conn, :publish_results, contest),
      "The results of these 2 performances were published."
    )
  end

  defp assert_certificates_success(conn) do
    assert html_response(conn, 200) =~ "Create certificates"
  end

  defp assert_advancing_success(conn) do
    assert html_response(conn, 200) =~ "Advancing performances"
  end

  defp assert_migrate_advancing_success(conn, contest) do
    assert_flash_redirect(
      conn,
      Routes.internal_contest_performances_path(conn, :advancing, contest),
      "2 performances were migrated."
    )
  end

  defp test_reschedule_success(conn, contest) do
    [s1, s2] = insert_list(2, :stage)
    st1 = ~N[2019-01-01T07:00:00]
    st2 = ~N[2019-01-02T07:00:00]
    p1 = insert_performance(contest, stage: nil, stage_time: nil)
    p2 = insert_performance(contest, stage: s1, stage_time: st1)
    p3 = insert_performance(contest, stage: s2, stage_time: st2)

    params = %{
      "performances" => %{
        p1.id => %{"stageId" => s1.id, "stageTime" => st1},
        p2.id => %{"stageId" => s2.id, "stageTime" => st2},
        p3.id => %{"stageId" => nil, "stageTime" => nil}
      }
    }

    conn =
      conn
      |> patch(Routes.internal_contest_performance_path(conn, :reschedule, contest), params)

    assert json_response(conn, 200) == %{
             "#{p1.id}" => %{"stageTime" => "2019-01-01T07:00:00"},
             "#{p2.id}" => %{"stageTime" => "2019-01-02T07:00:00"},
             "#{p3.id}" => %{"stageTime" => nil}
           }
  end

  defp assert_flash_redirect(conn, redirect_path, message) do
    assert redirected_to(conn) == redirect_path
    # Follow redirection
    conn = get(recycle(conn), redirect_path)
    assert html_response(conn, 200) =~ message
  end
end
