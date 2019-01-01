defmodule JumubaseWeb.Api.PerformanceController do
  use JumubaseWeb, :controller
  alias Jumubase.Foundation
  alias Jumubase.Showtime
  alias Jumubase.Showtime.PerformanceFilter

  def index(conn, %{"contest_id" => contest_id, "venue_id" => stage_id, "date" => date}) do
    contest = Foundation.get_contest!(contest_id)
    filter = %PerformanceFilter{
      stage_id: stage_id,
      stage_date: Date.from_iso8601!(date)
    }

    performances = Showtime.list_performances(contest, filter) |> Showtime.load_pieces

    conn
    |> assign(:performances, performances)
    |> render("index.json")
  end
end
