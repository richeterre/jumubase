defmodule JumubaseWeb.Internal.StageView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  import JumubaseWeb.Internal.PageView, only: [admin_email: 0]
  import JumubaseWeb.Internal.ParticipantView, only: [full_name: 1]
  import JumubaseWeb.Internal.PerformanceView, only: [
    cc_filter_options: 1, formatted_duration: 1
  ]
  alias Jumubase.Showtime
  alias Jumubase.Showtime.Instruments
  alias Jumubase.Showtime.Performance

  @pixels_per_minute 4 # for mapping duration to item height

  def render("scripts.schedule.html", %{conn: conn, contest: c, stage: s}) do
    options = render_html_safe_json %{
      csrfToken: Plug.CSRFProtection.get_csrf_token(),
      dictionary: %{
        intermission: gettext("Intermission"),
      },
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
  Returns a list of links to the given stages, with separators in between.
  """
  def stage_links(conn, contest, stages, separator) do
    stages
    |> Enum.map(fn s ->
      link s.name, to: Routes.internal_contest_stage_schedule_path(conn, :schedule, contest, s)
    end)
    |> Enum.intersperse(separator)
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
  def short_category_info(%Performance{contest_category: cc} = p) do
    "#{cc.category.short_name} #{p.age_group}"
  end

  @doc """
  Returns participant names and instruments of the performance's appearances.
  """
  def appearances_info(%Performance{appearances: appearances}) do
    appearances
    |> Enum.map(fn a -> "#{full_name(a.participant)}, #{Instruments.name(a.instrument)}" end)
    |> Enum.join("\n")
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
      "strings" -> "#f8e2e3" # red
      "percussion" -> "#fbeade" # orange
      "wind" -> "#f8f6e2" # yellow
      "pop_instrumental" -> "#eef8e2" # lime
      "plucked" -> "#e3f8e2" # green
      "kimu" -> "#e2f8f6" # emerald
      "special_lineups" -> "#e2f8f6" # turquoise
      "accordion" -> "#e2eef8" # azure
      "piano" -> "#e2e3f8" # blue
      g when g in ["harp", "organ"] -> "#ebe2f8" # indigo
      "classical_vocals" -> "#f6e2f8" # fuchsia
      "pop_vocals" -> "#f8e2ee" # pink
      _ -> "#ddd"
    end
  end

  @doc """
  Returns a map saying how much space (in minutes) lies after each performance.
  """
  def spacer_map([]), do: %{}
  def spacer_map(performances) do
    performances
    |> Enum.chunk_every(2, 1) # Chunk each performance with next one
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
    "#{total_minutes(p) / scheduled_minutes(p) * 100}%"
  end

  # Private helpers

  defp total_minutes(%Performance{} = performance) do
    Showtime.total_duration(performance) |> Timex.Duration.to_minutes
  end

  # Rounds the minutes up to the next grid step, or down if within tolerance margin.
  defp round_to_grid(minutes) do
    # Configure tolerance and grid size in minutes
    tolerance = 0.5
    grid_step = 5

    Float.ceil((minutes - tolerance) / grid_step) * grid_step + tolerance/grid_step
    |> trunc # Return number as integer
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
    for hour <- 8..17, minute <- Enum.take_every(0..59, 5) do
      {:ok, time} = Time.new(hour, minute, 0)
      label = Timex.format!(time, "%H:%M", :strftime)
      content_tag :option, label, value: time, selected: time == selected
    end
  end
end
