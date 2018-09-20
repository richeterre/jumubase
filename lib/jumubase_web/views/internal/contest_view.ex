defmodule JumubaseWeb.Internal.ContestView do
  use JumubaseWeb, :view

  alias Jumubase.JumuParams
  alias Jumubase.Foundation.Contest

  @doc """
  Returns a display name for the given contest.
  """
  def contest_name(%Contest{} = contest) do
    round_name = short_round_name(contest.round)
    contest_year = JumuParams.year(contest.season)
    flag_code = case contest.round do
      1 -> contest.host.country_code
      2 -> "EU"
    end
    "#{emoji_flag(flag_code)} #{contest.host.name}, #{round_name} #{contest_year}"
  end

  @doc """
  Returns the given contest's date(s) in a formatted way.
  """
  def contest_dates(%Contest{start_date: sd, end_date: ed}) do
    cond do
      sd == ed ->
        format_date(sd)
      true ->
        "#{format_date(sd)} – #{format_date(ed)}"
    end
  end

  @doc """
  Formats the given date for display.
  """
  def format_date(%Date{} = date) do
    format = "{D} {Mshort} {YYYY}"
    Timex.format!(date, format)
  end

  # Private helpers

  defp short_round_name(round) do
    case round do
      1 -> "RW"
      2 -> "LW"
      3 -> "BW"
    end
  end
end
