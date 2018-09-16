defmodule JumubaseWeb.PageControllerTest do
  use JumubaseWeb.ConnCase

  test "shows the welcome page", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Nord- und Osteuropa"
  end

  test "lists open contests on the signup page", %{conn: conn} do
    [c1, c2] = insert_list(2, :contest, signup_deadline: Timex.today)
    conn = get(conn, "/signup")
    assert html_response(conn, 200) =~ JumubaseWeb.PageView.contest_name(c1)
    assert html_response(conn, 200) =~ JumubaseWeb.PageView.contest_name(c2)
  end
end
