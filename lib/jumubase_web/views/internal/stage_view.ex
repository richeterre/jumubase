defmodule JumubaseWeb.Internal.StageView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.AppearanceView, only: [appearance_info: 1]
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  import JumubaseWeb.Internal.PageView, only: [admin_email: 0]

  import JumubaseWeb.Internal.PerformanceView,
    only: [
      category_name: 1,
      cc_filter_options: 1,
      formatted_duration: 1,
      sorted_appearances: 1,
      stage_date_filter_options: 1,
      stage_time: 1
    ]

  alias Jumubase.Showtime
  alias Jumubase.Showtime.Performance

  # Define a "minute grid" that durations get rounded to
  @grid_step 5

  # Map performance duration to item height
  @pixels_per_minute 4

  def scheduler_options(conn, contest, stage) do
    Jason.encode!(%{
      csrfToken: Plug.CSRFProtection.get_csrf_token(),
      dictionary: %{
        intermission: gettext("Intermission")
      },
      pixelsPerMinute: @pixels_per_minute,
      stageId: stage.id,
      submitPath: Routes.internal_contest_performance_path(conn, :reschedule, contest)
    })
  end

  @doc """
  Returns a list of links to the given stages' schedule pages, separated by dots.
  """
  def schedule_links(conn, contest, stages) do
    stages
    |> Enum.map(fn s ->
      link(s.name, to: Routes.internal_contest_stage_schedule_path(conn, :schedule, contest, s))
    end)
    |> with_dot_separators
  end

  @doc """
  Returns a list of links to the given stages' timetable pages, separated by dots.
  """
  def timetable_links(conn, contest, stages) do
    stages
    |> Enum.map(fn s ->
      link(s.name, to: Routes.internal_contest_stage_timetable_path(conn, :timetable, contest, s))
    end)
    |> with_dot_separators
  end

  @doc """
  Returns a list of options for a scheduler column's start time.
  If performances are passed, the first stage time will be the selected option.
  """
  def start_time_options([%Performance{stage_time: st} | _]) do
    NaiveDateTime.to_time(st) |> time_options
  end

  def start_time_options(_), do: time_options(nil)

  @doc """
  Returns shorthand category and age group information.
  """
  def shorthand_category_info(%Performance{contest_category: cc} = p) do
    "#{cc.category.short_name} #{p.age_group}"
  end

  @doc """
  Returns information about the performance's predecesser host,
  or nil if the performance has no predecessor host or is too short
  (less or equal to one grid step) for the info to be shown in the scheduler.
  """
  def predecessor_host_info(%Performance{predecessor_host: nil}), do: nil

  def predecessor_host_info(%Performance{predecessor_host: pre_h} = p) do
    grid_minutes = total_minutes(p) |> round_to_grid
    # Only return text if the performance is long enough for it to fit
    if grid_minutes > @grid_step, do: pre_h.name, else: nil
  end

  @doc """
  Returns participant names and instruments of the performance's appearances.
  """
  def appearances_info(%Performance{} = p) do
    sorted_appearances(p) |> Enum.map(&appearance_info/1) |> Enum.join("\n")
  end

  @doc """
  Returns the amount of minutes the performance occupies in the schedule.
  This does not necessarily equal the actual duration (due to overtime, rounding…)
  """
  def scheduled_minutes(%Performance{} = performance) do
    performance |> total_minutes |> round_to_grid
  end

  @doc """
  Returns the pixel height of the performance's schedule item.
  """
  def item_height(%Performance{} = performance) do
    performance |> scheduled_minutes |> to_pixels
  end

  def item_height(minutes), do: to_pixels(minutes)

  def item_color(%Performance{contest_category: %{category: cg}}) do
    case cg.group do
      "strings" -> "#f8e2e3"
      "percussion" -> "#fbeade"
      "wind" -> "#f8f6e2"
      "pop_instrumental" -> "#eef8e2"
      "plucked" -> "#e3f8e2"
      "kimu" -> "#e2f8f6"
      "special_lineups" -> "#e2f8f6"
      "accordion" -> "#e2eef8"
      "piano" -> "#e2e3f8"
      g when g in ["harp", "organ"] -> "#ebe2f8"
      "classical_vocals" -> "#f6e2f8"
      "pop_vocals" -> "#f8e2ee"
      _ -> "#ddd"
    end
  end

  @doc """
  Returns a map saying how much space (in minutes) lies after each performance.
  """
  def spacer_map([]), do: %{}

  def spacer_map(performances) do
    performances
    # Chunk each performance with next one
    |> Enum.chunk_every(2, 1)
    |> Enum.reduce(%{}, fn
      [%Performance{} = p1, %Performance{} = p2], acc ->
        acc |> Map.put(p1.id, minutes_between(p1, p2))

      [%Performance{} = p], acc ->
        # Last performance in list => no spacer after it
        acc |> Map.put(p.id, 0)
    end)
  end

  @doc """
  Returns the percentage taken up by playtime in the performance's schedule minutes.
  Example: 12' playtime scheduled as 15' => 80%
  """
  def playtime_percentage(%Performance{} = p) do
    case scheduled_minutes(p) do
      0 -> "0.0%"
      scheduled_minutes -> "#{total_minutes(p) / scheduled_minutes * 100}%"
    end
  end

  # Private helpers

  defp with_dot_separators(list) do
    list |> Enum.intersperse(" · ")
  end

  defp total_minutes(%Performance{} = performance) do
    Showtime.total_duration(performance) |> Timex.Duration.to_minutes()
  end

  # Rounds the minutes up to the next grid step, or down if within tolerance margin.
  defp round_to_grid(minutes) do
    # Configure tolerance and grid size in minutes
    tolerance = 0.5

    (Float.ceil((minutes - tolerance) / @grid_step) * @grid_step + tolerance / @grid_step)
    # Return number as integer
    |> trunc
  end

  defp to_pixels(minutes), do: "#{minutes * @pixels_per_minute}px"

  defp minutes_between(%Performance{} = p1, %Performance{} = p2) do
    p1_end_time = scheduled_end_time(p1)
    Timex.diff(p2.stage_time, p1_end_time, :minutes)
  end

  defp scheduled_end_time(%Performance{} = p) do
    Timex.shift(p.stage_time, minutes: scheduled_minutes(p))
  end

  defp time_options(selected) do
    for hour <- 7..17, minute <- Enum.take_every(0..59, 5) do
      {:ok, time} = Time.new(hour, minute, 0)
      label = Timex.format!(time, "%H:%M", :strftime)
      content_tag(:option, label, value: time, selected: time == selected)
    end
  end
end
