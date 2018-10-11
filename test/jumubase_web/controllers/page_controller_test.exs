defmodule JumubaseWeb.PageControllerTest do
  use JumubaseWeb.ConnCase
  alias JumubaseWeb.Internal.ContestView

  test "shows the welcome page", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Nord- und Osteuropa"
  end

  test "lists open contests on the registration page", %{conn: conn} do
    [c1, c2] = insert_list(2, :contest, deadline: Timex.today)
    conn = get(conn, "/registration")
    assert html_response(conn, 200) =~ "Registration"
    assert html_response(conn, 200) =~ ContestView.name_with_flag(c1)
    assert html_response(conn, 200) =~ ContestView.name_with_flag(c2)
  end

  test "lets users access their registration with a valid edit code", %{conn: conn} do
    c = insert(:contest)
    cc = insert_contest_category(c)
    edit_code = "123456"
    p = insert(:performance, contest_category: cc, edit_code: edit_code)

    conn = post(conn, "/edit-registration", search: %{edit_code: edit_code})
    assert redirected_to(conn) == performance_path(conn, :edit, c, p, edit_code: edit_code)
  end

  test "shows an error when submitting an unknown edit code", %{conn: conn} do
    conn = post(conn, "/edit-registration", search: %{edit_code: "unknown"})
    assert get_flash(conn, :error) =~ "We could not find a registration for this edit code."
    assert redirected_to(conn) == page_path(conn, :edit_registration)
  end

  test "shows an error when submitting an empty edit code", %{conn: conn} do
    conn = post(conn, "/edit-registration", search: %{edit_code: " "})
    assert get_flash(conn, :error) =~ "Please enter an edit code."
    assert redirected_to(conn) == page_path(conn, :edit_registration)
  end
end
