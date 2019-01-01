defmodule JumubaseWeb.Api.ContestController do
  use JumubaseWeb, :controller
  alias Jumubase.Foundation

  def index(conn, %{"timetables_public" => "1"}) do
    conn
    |> assign(:contests, Foundation.list_public_contests)
    |> render("index.json")
  end
end
