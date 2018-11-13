defmodule JumubaseWeb.PageControllerTest do
  use JumubaseWeb.ConnCase
  alias JumubaseWeb.Internal.ContestView

  test "shows the welcome page", %{conn: conn} do
    conn = get(conn, page_path(conn, :home))
    assert html_response(conn, 200) =~ "The website for “Jugend musiziert”"
  end

  describe "registration page" do
    test "lists open RW and Kimu contests", %{conn: conn} do
      kimu = insert(:contest, round: 0, deadline: Timex.today)
      rw = insert(:contest, round: 1, deadline: Timex.today)
      conn = get(conn, page_path(conn, :registration))

      assert html_response(conn, 200) =~ "Registration"
      assert html_response(conn, 200) =~ ContestView.name_with_flag(kimu)
      assert html_response(conn, 200) =~ ContestView.name_with_flag(rw)
    end

    test "does not list open LW contests", %{conn: conn} do
      lw = insert(:contest, round: 2, deadline: Timex.today)
      conn = get(conn, page_path(conn, :registration))

      refute html_response(conn, 200) =~ ContestView.name_with_flag(lw)
    end
  end

  describe "registration edit page" do
    test "lets users access their registration with a valid edit code", %{conn: conn} do
      c = insert(:contest)
      edit_code = "123456"
      p = insert_performance(c, edit_code: edit_code)

      conn = post(conn, page_path(conn, :lookup_registration), search: %{edit_code: edit_code})
      assert redirected_to(conn) == performance_path(conn, :edit, c, p, edit_code: edit_code)
    end

    test "shows an error when submitting an unknown edit code", %{conn: conn} do
      conn = post(conn, page_path(conn, :lookup_registration), search: %{edit_code: "unknown"})
      assert get_flash(conn, :error) =~ "We could not find a registration for this edit code."
      assert redirected_to(conn) == page_path(conn, :edit_registration)
    end

    test "shows an error when submitting an empty edit code", %{conn: conn} do
      conn = post(conn, page_path(conn, :lookup_registration), search: %{edit_code: " "})
      assert get_flash(conn, :error) =~ "Please enter an edit code."
      assert redirected_to(conn) == page_path(conn, :edit_registration)
    end
  end

  test "shows the rules page", %{conn: conn} do
    conn = get(conn, page_path(conn, :rules))
    assert html_response(conn, 200) =~ "Rules"
  end
end
