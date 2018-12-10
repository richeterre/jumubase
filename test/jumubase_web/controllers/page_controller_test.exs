defmodule JumubaseWeb.PageControllerTest do
  use JumubaseWeb.ConnCase
  alias JumubaseWeb.Internal.ContestView

  describe "home/2" do
    test "shows the welcome page", %{conn: conn} do
      conn = get(conn, Routes.page_path(conn, :home))
      assert html_response(conn, 200) =~ "The website for “Jugend musiziert”"
    end
  end

  describe "registration/2" do
    test "lists open RW and Kimu contests", %{conn: conn} do
      kimu = insert(:contest, round: 0, deadline: Timex.today)
      rw = insert(:contest, round: 1, deadline: Timex.today)
      conn = get(conn, Routes.page_path(conn, :registration))

      assert html_response(conn, 200) =~ "Registration"
      assert html_response(conn, 200) =~ ContestView.name_with_flag(kimu)
      assert html_response(conn, 200) =~ ContestView.name_with_flag(rw)
    end

    test "does not list open LW contests", %{conn: conn} do
      lw = insert(:contest, round: 2, deadline: Timex.today)
      conn = get(conn, Routes.page_path(conn, :registration))

      refute html_response(conn, 200) =~ ContestView.name_with_flag(lw)
    end
  end

  describe "edit_registration/2" do
    @today Timex.today
    @yesterday Timex.shift(@today, days: -1)

    setup context do
      deadline = Map.get(context, :deadline, @today)
      c = insert(:contest, deadline: deadline)
      [contest: c, performance: insert_performance(c)]
    end

    test "lets users access a registration with a valid edit code within the deadline", %{conn: conn, contest: c, performance: p} do
      conn = post(conn, Routes.page_path(conn, :lookup_registration), search: %{edit_code: p.edit_code})
      assert redirected_to(conn) == Routes.performance_path(conn, :edit, c, p, edit_code: p.edit_code)
    end

    @tag deadline: @yesterday
    test "shows an error when the contest's deadline has passed", %{conn: conn, performance: p} do
      conn = post(conn, Routes.page_path(conn, :lookup_registration), search: %{edit_code: p.edit_code})
      assert get_flash(conn, :error) == "The edit deadline for this contest has passed. Please contact us if you need assistance."
      assert redirected_to(conn) == Routes.page_path(conn, :edit_registration)
    end

    test "shows an error when submitting an unknown edit code", %{conn: conn} do
      conn = post(conn, Routes.page_path(conn, :lookup_registration), search: %{edit_code: "unknown"})
      assert get_flash(conn, :error) =~ "We could not find a registration for this edit code."
      assert redirected_to(conn) == Routes.page_path(conn, :edit_registration)
    end

    test "shows an error when submitting an empty edit code", %{conn: conn} do
      conn = post(conn, Routes.page_path(conn, :lookup_registration), search: %{edit_code: " "})
      assert get_flash(conn, :error) =~ "Please enter an edit code."
      assert redirected_to(conn) == Routes.page_path(conn, :edit_registration)
    end
  end

  describe "rules/2" do
    test "shows the rules page", %{conn: conn} do
      conn = get(conn, Routes.page_path(conn, :rules))
      assert html_response(conn, 200) =~ "Rules"
    end
  end
end
