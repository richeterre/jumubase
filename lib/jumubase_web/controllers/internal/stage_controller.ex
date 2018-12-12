defmodule JumubaseWeb.Internal.StageController do
  use JumubaseWeb, :controller
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Contest
  alias Jumubase.Showtime
  alias Jumubase.Showtime.PerformanceFilter

  plug :add_home_breadcrumb
  plug :add_breadcrumb, name: gettext("Contests"), path_fun: &Routes.internal_contest_path/2, action: :index

  # Check nested contest permissions and pass to all actions
  def action(conn, _), do: contest_user_check_action(conn, __MODULE__)

  def index(conn, _params, contest) do
    %{host: %{stages: stages}} = Foundation.load_stages(contest)
    stages = stages |> Enum.sort_by(&(&1.name))

    conn
    |> assign(:contest, contest)
    |> assign(:stages, stages)
    |> add_breadcrumbs(contest)
    |> render("index.html")
  end

  def schedule(conn, %{"stage_id" => stage_id}, contest) do
    stage = Foundation.get_stage!(contest, stage_id)
    date_range = Date.range(contest.start_date, contest.end_date)

    # Group performances by stage date
    performances = Enum.reduce(
      date_range,
      %{unscheduled: Showtime.unscheduled_performances(contest)},
      fn date, acc ->
        filter = %PerformanceFilter{stage_date: date, stage_id: stage_id}
        Map.put(acc, date, Showtime.list_performances(contest, filter))
      end
    )

    conn
    |> assign(:contest, contest)
    |> assign(:stage, stage)
    |> assign(:date_range, date_range)
    |> assign(:performances, performances)
    |> add_breadcrumbs(contest)
    |> add_breadcrumb(name: stage.name, path: current_path(conn))
    |> render("schedule.html")
  end

  defp add_breadcrumbs(conn, %Contest{} = contest) do
    index_path = Routes.internal_contest_stage_path(conn, :index, contest)

    conn
    |> add_contest_breadcrumb(contest)
    |> add_breadcrumb(name: gettext("Schedule performances"), path: index_path)
  end
end
