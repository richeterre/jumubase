defmodule JumubaseWeb.Internal.ContestView do
  use JumubaseWeb, :view
  alias Ecto.Changeset
  alias Jumubase.JumuParams
  alias Jumubase.Foundation.Contest
  alias Jumubase.Foundation.AgeGroups
  alias Jumubase.Showtime
  alias JumubaseWeb.Internal.ContestLive

  @doc """
  Returns a display name for the contest.
  """
  def name(%Contest{} = contest) do
    round_name = short_round_name(contest.round)

    "#{round_name} #{contest.host.name} #{year(contest)} #{contest.name_suffix}"
    |> String.trim()
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

  @doc """
  Returns a list of possible `grouping` values suitable for forms.
  """
  def grouping_options do
    JumuParams.groupings()
  end

  @doc """
  Returns a range of years suitable for dates related to the contest,
  such deadline, start or end date.
  """
  def dates_year_range(%Contest{season: season}) do
    season_year = JumuParams.year(season)
    (season_year - 1)..season_year
  end

  @doc """
  Returns the year for a valid season found in the changeset, or nil.
  """
  def year_for_season(%Changeset{} = changeset) do
    season = Changeset.get_field(changeset, :season)

    if !changeset.errors[:season] and season,
      do: "#{JumuParams.year(season)}",
      else: "––––"
  end

  @doc """
  Returns the number of contest categories in the changeset.
  """
  def contest_category_count(%Changeset{} = changeset) do
    changeset |> Changeset.get_field(:contest_categories) |> Enum.count()
  end

  def filter_status(count, true) do
    [count_tag(count), " ", active_filter_label()]
  end

  def filter_status(count, false), do: count_tag(count)

  # Private helpers

  defp short_round_name(round) do
    case round do
      0 -> "Kimu"
      1 -> "RW"
      2 -> "LW"
      3 -> "BW"
    end
  end

  defp count_tag(count) do
    content_tag(
      :span,
      ngettext("%{count} contest", "%{count} contests", count),
      class: "text-muted"
    )
  end

  defp active_filter_label do
    content_tag(:span, gettext("Filter active"), class: "label label-warning")
  end
end
