defmodule JumubaseWeb.ContestResolver do
  alias JumubaseWeb.Internal.ContestView

  def public_contests(_, _) do
    {:ok, Jumubase.Foundation.list_public_contests()}
  end

  def dates(_, %{source: contest}) do
    dates =
      cond do
        contest.start_date == contest.end_date ->
          [contest.start_date]

        Timex.shift(contest.start_date, days: 1) === contest.end_date ->
          [contest.start_date, contest.end_date]

        true ->
          [contest.start_date, Timex.shift(contest.start_date, days: 1), contest.end_date]
      end

    {:ok, dates}
  end

  def stages(_, %{source: contest}) do
    {:ok, contest.host.stages}
  end

  def name(_args, %{source: contest}) do
    {:ok, ContestView.name(contest)}
  end

  def country_code(_args, %{source: contest}) do
    {:ok, contest.host.country_code}
  end
end
