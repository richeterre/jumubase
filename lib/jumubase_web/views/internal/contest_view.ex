defmodule JumubaseWeb.Internal.ContestView do
  use JumubaseWeb, :view

  alias Jumubase.JumuParams
  alias Jumubase.Foundation.Contest

  def contest_name(%Contest{} = contest) do
    round_name = short_round_name(contest.round)
    contest_year = JumuParams.year(contest.season)
    "#{emoji_flag(contest.host.country_code)} #{contest.host.name}, #{round_name} #{contest_year}"
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
