defmodule JumubaseWeb.PageController do
  use JumubaseWeb, :controller
  alias Jumubase.Foundation

  def home(conn, _params) do
    render(conn, "home.html")
  end

  def signup(conn, _params) do
    conn
    |> assign(:contests, Foundation.list_open_contests)
    |> render("signup.html")
  end
end
