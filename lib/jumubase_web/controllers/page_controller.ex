defmodule JumubaseWeb.PageController do
  use JumubaseWeb, :controller
  alias Jumubase.Foundation

  def home(conn, _params) do
    render(conn, "home.html")
  end

  def registration(conn, _params) do
    conn
    |> assign(:contests, Foundation.list_open_contests)
    |> render("registration.html")
  end
end
