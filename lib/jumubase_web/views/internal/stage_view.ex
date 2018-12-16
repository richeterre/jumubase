defmodule JumubaseWeb.Internal.StageView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  import JumubaseWeb.Internal.PerformanceView, only: [
    category_name: 1, cc_filter_options: 1, formatted_duration: 1
  ]
  alias Jumubase.Showtime
  alias Jumubase.Showtime.Performance

  @pixels_per_minute 4 # for mapping duration to item height

  def render("scripts.schedule.html", %{conn: conn, contest: c, stage: s}) do
    options = render_html_safe_json %{
      csrfToken: Plug.CSRFProtection.get_csrf_token(),
      pixelsPerMinute: @pixels_per_minute,
      stageId: s.id,
      submitPath: Routes.internal_contest_performance_path(conn, :reschedule, c),
    }

    ~E{
      <script src="/js/scheduler.js"></script>
      <script>scheduler(<%= raw(options) %>)</script>
    }
  end

  @doc """
  Returns the amount of minutes the performance occupies in the schedule.
  This does not necessarily equal the actual duration (due to overtime, rounding…)
  """
  def schedule_minutes(%Performance{} = performance) do
    performance |> total_minutes |> round_up
  end

  @doc """
  Returns the pixel height of the performance's schedule item.
  """
  def item_height(%Performance{} = performance) do
    performance |> schedule_minutes |> to_pixels
  end

  @doc """
  Returns the percentage taken up by playtime in the performance's schedule minutes.
  Example: 12' playtime scheduled as 15' => 80%
  """
  def playtime_percentage(%Performance{} = p) do
    "#{total_minutes(p) / schedule_minutes(p) * 100}%"
  end

  # Private helpers

  defp total_minutes(%Performance{} = performance) do
    Showtime.total_duration(performance) |> Timex.Duration.to_minutes
  end

  defp round_up(minutes) do
    Float.ceil(minutes / 5) * 5 |> trunc
  end

  defp to_pixels(minutes), do: "#{minutes * @pixels_per_minute}px"
end
