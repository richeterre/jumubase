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
end
