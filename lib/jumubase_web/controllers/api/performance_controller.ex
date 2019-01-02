defmodule JumubaseWeb.Api.PerformanceController do
  use JumubaseWeb, :controller
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Contest
  alias Jumubase.Showtime
  alias Jumubase.Showtime.PerformanceFilter

  def index(conn, %{"contest_id" => contest_id, "venue_id" => stage_id, "date" => date}) do
    contest = Foundation.get_public_contest!(contest_id)

    # Parse date, which some clients unfortunately send without leading zeroes (e.g. 2018-1-31)
    case Timex.parse(date, "{YYYY}-{M}-{D}") do
      {:ok, datetime} ->
        stage_date = NaiveDateTime.to_date(datetime)
        filter = PerformanceFilter.from_params(%{stage_id: stage_id, stage_date: stage_date})
        conn |> render_performances(contest, filter)
      {:error, _} ->
        handle_bad_request(conn)
    end
  end
  def index(conn, %{"contest_id" => contest_id, "contest_category_id" => cc_id, "results_public" => results_public}) do
    contest = Foundation.get_public_contest!(contest_id)

    filter = PerformanceFilter.from_params(%{contest_category_id: cc_id, results_public: results_public})
    conn |> render_performances(contest, filter)
  end
  def index(conn, _params), do: handle_bad_request(conn)

  # Private helpers

  defp render_performances(conn, %Contest{} = c, %PerformanceFilter{} = filter) do
    performances = Showtime.list_performances(c, filter) |> Showtime.load_pieces

    conn
    |> assign(:performances, performances)
    |> render("index.json")
  end

  defp handle_bad_request(conn) do
    conn |> send_resp(400, "")
  end
end
