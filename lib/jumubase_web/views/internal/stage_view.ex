defmodule JumubaseWeb.Internal.StageView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  import JumubaseWeb.Internal.ParticipantView, only: [full_name: 1]
  import JumubaseWeb.Internal.PerformanceView, only: [
    cc_filter_options: 1, formatted_duration: 1
  ]
  alias Jumubase.Showtime
  alias Jumubase.Showtime.Performance

  @pixels_per_minute 4 # for mapping duration to item height
  @start_time ~T[09:00:00]

  def render("scripts.schedule.html", %{conn: conn, contest: c, stage: s}) do
    options = render_html_safe_json %{
      csrfToken: Plug.CSRFProtection.get_csrf_token(),
      pixelsPerMinute: @pixels_per_minute,
      stageId: s.id,
      startTime: @start_time,
      submitPath: Routes.internal_contest_performance_path(conn, :reschedule, c),
    }

    ~E{
      <script src="/js/scheduler.js"></script>
      <script>scheduler(<%= raw(options) %>)</script>
    }
  end

  def short_category_info(%Performance{} = performance) do
    "#{performance.contest_category.category.short_name} #{performance.age_group}"
  end

  @doc """
  Returns the full names of the performance's participants, separated by commas.
  """
  def participant_names(%Performance{appearances: appearances}) do
    appearances
    |> Enum.map(fn %{participant: pt} -> full_name(pt) end)
    |> Enum.join(", ")
  end

  @doc """
  Returns the amount of minutes the performance occupies in the schedule.
  This does not necessarily equal the actual duration (due to overtime, rounding…)
  """
  def scheduled_minutes(%Performance{} = performance) do
    performance |> total_minutes |> round_up
  end

  @doc """
  Returns the pixel height of the performance's schedule item.
  """
  def item_height(%Performance{} = performance) do
    performance |> scheduled_minutes |> to_pixels
  end
  def item_height(minutes), do: to_pixels(minutes)

  @doc """
  Returns a map specifying how many minutes of space lie before the performances.
  """
  def spacer_map(_date, []), do: %{}
  def spacer_map(%Date{} = date, performances) do
    start = to_utc_datetime(date, @start_time)
    chunks = Enum.chunk_every([start | performances], 2, 1)

    Enum.reduce(chunks, %{}, fn
      [%DateTime{} = start, %Performance{} = p], acc ->
        acc |> Map.put(p.id, minutes_between(start, p))
      [%Performance{} = p1, %Performance{} = p2], acc ->
        acc |> Map.put(p2.id, minutes_between(p1, p2))
      [%Performance{}], acc ->
        acc
    end)
  end

  @doc """
  Returns the percentage taken up by playtime in the performance's schedule minutes.
  Example: 12' playtime scheduled as 15' => 80%
  """
  def playtime_percentage(%Performance{} = p) do
    "#{total_minutes(p) / scheduled_minutes(p) * 100}%"
  end

  # Private helpers

  defp total_minutes(%Performance{} = performance) do
    Showtime.total_duration(performance) |> Timex.Duration.to_minutes
  end

  defp round_up(minutes) do
    Float.ceil(minutes / 5) * 5 |> trunc
  end

  defp to_pixels(minutes), do: "#{minutes * @pixels_per_minute}px"

  defp minutes_between(%Performance{} = p1, %Performance{} = p2) do
    p1 |> scheduled_end_time |> minutes_between(p2)
  end
  defp minutes_between(%DateTime{} = datetime, %Performance{stage_time: stage_time}) do
    Timex.diff(stage_time, datetime, :minutes)
  end

  defp scheduled_end_time(%Performance{} = p) do
    Timex.shift(p.stage_time, minutes: scheduled_minutes(p))
  end
end
