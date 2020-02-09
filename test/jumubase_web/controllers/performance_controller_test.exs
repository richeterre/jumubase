defmodule JumubaseWeb.PerformanceControllerTest do
  use JumubaseWeb.ConnCase
  use Bamboo.Test
  alias Jumubase.Repo
  alias Jumubase.Showtime.Performance

  @today Timex.today()
  @yesterday Timex.shift(@today, days: -1)

  setup context do
    deadline = Map.get(context, :deadline, @today)
    allows_registration = Map.get(context, :allows_registration, true)

    contest = insert(:contest, deadline: deadline, allows_registration: allows_registration)
    [contest: contest |> with_contest_categories]
  end

  describe "new/3" do
    test "shows a registration form", %{conn: conn, contest: c} do
      conn = get(conn, Routes.performance_path(conn, :new, c))
      assert html_response(conn, 200) =~ "Register"
    end

    @tag deadline: @yesterday
    test "shows an error if the contest deadline has passed", %{conn: conn, contest: c} do
      conn = get(conn, Routes.performance_path(conn, :new, c))
      assert_deadline_error(conn)
    end

    @tag allows_registration: false
    test "shows an error if the contest allows no registration", %{conn: conn, contest: c} do
      conn = get(conn, Routes.performance_path(conn, :new, c))
      assert_allows_no_registration_error(conn)
    end
  end

  describe "create/3" do
    test "lets the user register for a contest", %{conn: conn, contest: c} do
      [cc, _] = c.contest_categories
      params = valid_performance_params(cc)

      conn = post(conn, Routes.performance_path(conn, :create, c), params)

      # Check that performance was inserted correctly
      assert performance = get_inserted_performance()
      assert performance.contest_category_id == cc.id
      assert [%{participant: %{email: "ab@cd.ef"}}] = performance.appearances

      # Check response page
      redirect_path = Routes.page_path(conn, :home)
      assert redirected_to(conn) == redirect_path
      # Follow redirection
      conn = get(recycle(conn), redirect_path)
      assert html_response(conn, 200) =~ "We received your registration"
      assert html_response(conn, 200) =~ performance.edit_code
    end

    test "sends a confirmation mail upon registration", %{conn: conn, contest: c} do
      [cc, _] = c.contest_categories
      params = valid_performance_params(cc)

      post(conn, Routes.performance_path(conn, :create, c), params)
      performance = get_inserted_performance()

      assert_delivered_email(JumubaseWeb.Email.registration_success(performance))
    end

    test "re-renders form with errors when user submits invalid data", %{conn: conn, contest: c} do
      [cc, _] = c.contest_categories

      params = %{
        "performance" => %{
          "contest_category_id" => cc.id,
          "appearances" => []
        }
      }

      conn = post(conn, Routes.performance_path(conn, :create, c), params)
      assert html_response(conn, 200) =~ "Register"
      assert Repo.all(Performance) == []
    end

    test "handles a completely empty form submission", %{conn: conn, contest: c} do
      params = %{}
      conn = post(conn, Routes.performance_path(conn, :create, c), params)
      assert html_response(conn, 200) =~ "Register"
    end

    @tag deadline: @yesterday
    test "shows an error if the contest deadline has passed", %{conn: conn, contest: c} do
      [cc, _] = c.contest_categories
      params = valid_performance_params(cc)

      conn = post(conn, Routes.performance_path(conn, :create, c), params)
      assert_deadline_error(conn)
    end

    @tag allows_registration: false
    test "shows an error if the contest allows no registration", %{conn: conn, contest: c} do
      [cc, _] = c.contest_categories
      params = valid_performance_params(cc)

      conn = post(conn, Routes.performance_path(conn, :create, c), params)
      assert_allows_no_registration_error(conn)
    end
  end

  describe "edit/3" do
    setup %{contest: c} do
      performance = insert_performance(c)
      [performance: performance]
    end

    test "shows the edit form for a valid edit code", %{conn: conn, contest: c, performance: p} do
      conn
      |> get(Routes.performance_path(conn, :edit, c, p, edit_code: p.edit_code))
      |> assert_edit_success
    end

    test "returns an error when the contest doesn't match", %{conn: conn, performance: p} do
      other_c = insert(:contest, deadline: @today)

      assert_error_sent 404, fn ->
        get(conn, Routes.performance_path(conn, :edit, other_c, p, edit_code: p.edit_code))
      end
    end

    test "returns an error for a missing edit code", %{conn: conn, contest: c, performance: p} do
      assert_error_sent 400, fn ->
        get(conn, Routes.performance_path(conn, :edit, c, p))
      end
    end

    test "returns an error for an invalid edit code", %{conn: conn, contest: c, performance: p} do
      assert_error_sent 404, fn ->
        get(conn, Routes.performance_path(conn, :edit, c, p, edit_code: "999999"))
      end
    end

    @tag deadline: @yesterday
    test "shows an error when the contest deadline has passed", %{
      conn: conn,
      contest: c,
      performance: p
    } do
      conn = get(conn, Routes.performance_path(conn, :edit, c, p, edit_code: p.edit_code))
      assert_deadline_error(conn)
    end

    @tag allows_registration: false
    test "shows the edit form even if the contest allows no registration", %{
      conn: conn,
      contest: c,
      performance: p
    } do
      conn
      |> get(Routes.performance_path(conn, :edit, c, p, edit_code: p.edit_code))
      |> assert_edit_success()
    end
  end

  describe "update/3" do
    setup %{contest: c} do
      [cc1, _cc2] = c.contest_categories
      [performance: insert_performance(cc1)]
    end

    test "updates a registration with a valid edit code", %{
      conn: conn,
      contest: c,
      performance: p
    } do
      [_cc1, cc2] = c.contest_categories
      params = valid_performance_params(cc2)

      conn
      |> put(Routes.performance_path(conn, :update, c, p, edit_code: p.edit_code), params)
      |> assert_update_success()
    end

    test "returns an error when the contest doesn't match", %{
      conn: conn,
      contest: c,
      performance: p
    } do
      [_cc1, cc2] = c.contest_categories
      other_c = insert(:contest, deadline: @today)
      params = valid_performance_params(cc2)

      assert_error_sent 404, fn ->
        put(
          conn,
          Routes.performance_path(conn, :update, other_c, p, edit_code: p.edit_code),
          params
        )
      end
    end

    test "returns an error for a missing edit code", %{conn: conn, contest: c, performance: p} do
      [_cc1, cc2] = c.contest_categories
      params = valid_performance_params(cc2)

      assert_error_sent 400, fn ->
        put(conn, Routes.performance_path(conn, :update, c, p), params)
      end
    end

    test "returns an error for an invalid edit code", %{conn: conn, contest: c, performance: p} do
      [_cc1, cc2] = c.contest_categories
      params = valid_performance_params(cc2)

      assert_error_sent 404, fn ->
        put(conn, Routes.performance_path(conn, :update, c, p, edit_code: "999999"), params)
      end
    end

    @tag deadline: @yesterday
    test "shows an error if the contest deadline has passed", %{
      conn: conn,
      contest: c,
      performance: p
    } do
      [_cc1, cc2] = c.contest_categories
      params = valid_performance_params(cc2)

      conn
      |> put(Routes.performance_path(conn, :update, c, p, edit_code: p.edit_code), params)
      |> assert_deadline_error
    end

    @tag allows_registration: false
    test "updates a performance even if the contest allows no registration", %{
      conn: conn,
      contest: c,
      performance: p
    } do
      [_cc1, cc2] = c.contest_categories
      params = valid_performance_params(cc2)

      conn
      |> put(Routes.performance_path(conn, :update, c, p, edit_code: p.edit_code), params)
      |> assert_update_success()
    end

    test "shows an error if the performance already has results", %{conn: conn, contest: c} do
      p = insert_performance(c, appearances: [build(:appearance, points: 1)])
      [_cc1, cc2] = c.contest_categories
      params = valid_performance_params(cc2)

      conn
      |> put(Routes.performance_path(conn, :update, c, p, edit_code: p.edit_code), params)
      |> assert_has_results_error
    end
  end

  # Private helpers

  defp get_inserted_performance do
    Repo.one(Performance) |> Repo.preload(appearances: :participant)
  end

  defp assert_edit_success(conn) do
    assert html_response(conn, 200) =~ "Edit registration"
  end

  defp assert_update_success(conn) do
    assert get_flash(conn, :success) == "Your changes to the registration were saved."
    assert redirected_to(conn) == Routes.page_path(conn, :home)
  end

  defp assert_deadline_error(conn) do
    assert get_flash(conn, :error) ==
             "The registration deadline for this contest has passed. Please contact us if you need assistance."

    assert redirected_to(conn) == Routes.page_path(conn, :registration)
  end

  defp assert_allows_no_registration_error(conn) do
    assert get_flash(conn, :error) ==
             "This contest is not open for registration. Please contact us if you need assistance."

    assert redirected_to(conn) == Routes.page_path(conn, :registration)
  end

  defp assert_has_results_error(conn) do
    assert get_flash(conn, :error) ==
             "Your changes could not be saved. Please contact us if you need assistance."

    assert redirected_to(conn) == Routes.page_path(conn, :edit_registration)
  end
end
