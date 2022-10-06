defmodule JumubaseWeb.Internal.StageController do
  use JumubaseWeb, :controller
  alias Jumubase.Foundation
  alias Jumubase.Foundation.{Contest, Stage}
  alias Jumubase.Showtime
  alias Jumubase.Showtime.PerformanceFilter
  alias JumubaseWeb.Internal.ContestLive

  plug :add_home_breadcrumb

  plug :add_breadcrumb,
    name: gettext("Contests"),
    path_fun: &Routes.internal_live_path/2,
    action: ContestLive.Index

  # Check nested contest permissions and pass to all actions
  def action(conn, _), do: contest_user_check_action(conn, __MODULE__)

  def index(conn, _params, contest) do
    %{host: %{stages: stages}} = Foundation.load_available_stages(contest)
    stages = stages |> Enum.sort_by(& &1.name)

    unscheduled_performance_count = Showtime.unscheduled_performance_count(contest)

    conn
    |> assign(:contest, contest)
    |> assign(:stages, stages)
    |> assign(:unscheduled_performance_count, unscheduled_performance_count)
    |> add_schedule_breadcrumbs(contest)
    |> render("index.html")
  end

  def schedule(conn, %{"stage_id" => stage_id}, contest) do
    stage = Foundation.get_stage!(contest, stage_id)
    %{host: %{stages: stages}} = Foundation.load_available_stages(contest)
    date_range = Foundation.date_range(contest)

    unscheduled_performances =
      Showtime.unscheduled_performances(contest)
      |> Showtime.load_pieces()
      |> Showtime.load_predecessor_hosts()

    # Group performances by stage date
    performances =
      Enum.reduce(
        date_range,
        %{unscheduled: unscheduled_performances},
        fn date, acc ->
          filter = %PerformanceFilter{stage_date: date, stage_id: stage_id}

          performances =
            Showtime.list_performances(contest, filter)
            |> Showtime.load_pieces()
            |> Showtime.load_predecessor_hosts()

          Map.put(acc, date, performances)
        end
      )

    conn
    |> assign(:contest, contest)
    |> assign(:stage, stage)
    |> assign(:other_stages, exclude(stages, stage))
    |> assign(:date_range, date_range)
    |> assign(:performances, performances)
    |> add_schedule_breadcrumbs(contest)
    |> add_breadcrumb(name: stage.name, path: current_path(conn))
    |> add_public_schedule_warning(contest)
    |> render("schedule.html")
  end

  def timetable(conn, %{"stage_id" => stage_id} = params, contest) do
    stage = Foundation.get_stage!(contest, stage_id)
    %{host: %{stages: stages}} = Foundation.load_used_stages(contest)

    filter_params =
      %{"stage_id" => stage_id, "stage_date" => contest.start_date}
      |> Map.merge(params["performance_filter"] || %{})

    filter = PerformanceFilter.from_params(filter_params)
    filter_cs = PerformanceFilter.changeset(filter_params)
    performances = Showtime.list_performances(contest, filter)

    conn
    |> assign(:contest, contest)
    |> assign(:stage, stage)
    |> assign(:other_stages, exclude(stages, stage))
    |> assign(:filter_changeset, filter_cs)
    |> assign(:date, filter.stage_date)
    |> assign(:performances, performances)
    |> add_contest_breadcrumb(contest)
    |> add_timetable_breadcrumb(stage)
    |> render("timetable.html")
  end

  # Private helpers

  defp exclude(stages, %Stage{id: id}) do
    stages |> Enum.filter(&(&1.id != id))
  end

  defp add_schedule_breadcrumbs(conn, %Contest{} = contest) do
    index_path = Routes.internal_contest_stage_path(conn, :index, contest)

    conn
    |> add_contest_breadcrumb(contest)
    |> add_breadcrumb(name: gettext("Schedule performances"), path: index_path)
  end

  defp add_timetable_breadcrumb(conn, %Stage{} = stage) do
    name = gettext("Timetable") <> ": " <> stage.name
    add_breadcrumb(conn, name: name, path: current_path(conn))
  end

  defp add_public_schedule_warning(conn, %Contest{timetables_public: true}) do
    conn
    |> put_flash(
      :warning,
      gettext(
        "This schedule has already been published. Your changes will be visible to others instantly."
      )
    )
  end

  defp add_public_schedule_warning(conn, %Contest{timetables_public: false}), do: conn
end
