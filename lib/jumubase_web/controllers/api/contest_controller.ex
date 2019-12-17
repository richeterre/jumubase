defmodule JumubaseWeb.Api.ContestController do
  use JumubaseWeb, :controller
  alias Jumubase.Foundation

  def index(conn, %{"timetables_public" => "1", "current_only" => current_only}) do
    conn
    |> assign(:contests, Foundation.list_public_contests(current_only: current_only == "1"))
    |> render("index.json")
  end
end
