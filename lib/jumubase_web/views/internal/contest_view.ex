defmodule JumubaseWeb.Internal.ContestView do
  use JumubaseWeb, :view
  alias Jumubase.JumuParams
  alias Jumubase.Foundation.Contest
  alias Jumubase.Showtime

  @doc """
  Returns a display name for the contest.
  """
  def name(%Contest{} = contest) do
    round_name = short_round_name(contest.round)
    "#{round_name} #{contest.host.name} #{year(contest)}"
  end

  @doc """
  Returns the flag associated with the contest's host.
  """
  def flag(%Contest{host: host}) do
    emoji_flag(host.country_code)
  end

  @doc """
  Returns a display name for the contest that includes a host flag.
  """
  def name_with_flag(%Contest{} = contest) do
    flag_code = contest.host.country_code
    "#{emoji_flag(flag_code)} #{name(contest)}"
  end

  def city(%Contest{host: host}), do: host.city

  @doc """
  Returns the deadline in full-length format.
  """
  def deadline(%Contest{deadline: deadline}) do
    format_date(deadline, :full)
  end

  @doc """
  Returns formatted deadline info in case the contest's deadline
  doesn't match the general deadline.
  """
  def deadline_info(%Contest{deadline: deadline}, general_deadline) do
    case deadline do
      ^general_deadline ->
        nil

      _ ->
        deadline_tag = content_tag(:strong, format_date(deadline, :medium))
        "(#{gettext("Deadline")}: #{safe_to_string(deadline_tag)})" |> raw
    end
  end

  @doc """
  Returns the given contest's date(s) in a formatted way.
  """
  def dates(%Contest{start_date: sd, end_date: ed}) do
    cond do
      sd == ed -> format_date(sd)
      true -> "#{format_date(sd)} – #{format_date(ed)}"
    end
  end

  @doc """
  Returns the given contest's year (based on the season).
  """
  def year(%Contest{season: season}) do
    JumuParams.year(season)
  end

  @doc """
  Returns the user-facing name of the given round.
  """
  def round_name(round) do
    case round do
      0 -> "„Kinder musizieren“"
      1 -> "Regionalwettbewerb"
      2 -> "Landeswettbewerb"
      3 -> "Bundeswettbewerb"
    end
  end

  def round_name_and_year(%Contest{round: round} = contest) do
    "#{round_name(round)} #{year(contest)}"
  end

  @doc """
  Returns a link path for scheduling performances. If the contest has only one stage,
  we can guide the user to that stage directly, else we take them to the index page.
  """
  def schedule_link_path(conn, %Contest{host: host} = contest) do
    case host.stages do
      [stage] ->
        Routes.internal_contest_stage_schedule_path(conn, :schedule, contest, stage)

      _ ->
        Routes.internal_contest_stage_path(conn, :index, contest)
    end
  end

  def edit_points_completion_text(%{total: total, with_points: completed}) do
    case completed do
      ^total -> gettext("All %{total} entered", total: total)
      _ -> gettext("%{completed} of %{total} entered so far", completed: completed, total: total)
    end
  end

  def publish_results_completion_text(%{total: total, public: completed}) do
    case completed do
      ^total ->
        gettext("All %{total} published", total: total)

      _ ->
        gettext("%{completed} of %{total} published so far", completed: completed, total: total)
    end
  end

  @doc """
  Renders a statistics template based on the contest's round.
  """
  def render_statistics(performances, 0) do
    render("_kimu_stats.html", stats: Showtime.statistics(performances, 0))
  end

  def render_statistics(performances, round) do
    render("_jumu_stats.html", stats: Showtime.statistics(performances, round))
  end

  @doc """
  Returns a list of possible `round` values suitable for forms.
  """
  def round_options do
    Enum.map(JumuParams.rounds(), &{round_name(&1), &1})
  end

  # Private helpers

  defp short_round_name(round) do
    case round do
      0 -> "Kimu"
      1 -> "RW"
      2 -> "LW"
      3 -> "BW"
    end
  end
end
