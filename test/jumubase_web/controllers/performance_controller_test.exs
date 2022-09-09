defmodule JumubaseWeb.PerformanceControllerTest do
  use JumubaseWeb.ConnCase

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

  # Private helpers

  defp assert_edit_success(conn) do
    assert html_response(conn, 200) =~ "Edit registration"
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
end
