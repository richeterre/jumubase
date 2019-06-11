defmodule JumubaseWeb.ContestResolver do
  alias Jumubase.Foundation
  alias JumubaseWeb.Internal.ContestView

  def public_contests(_, _) do
    {:ok, Foundation.list_public_contests()}
  end

  def name(_args, %{source: contest}) do
    {:ok, ContestView.name(contest)}
  end

  def country_code(_args, %{source: contest}) do
    {:ok, contest.host.country_code}
  end

  def dates(_, %{source: contest}) do
    {:ok, Foundation.date_range(contest) |> Enum.to_list()}
  end

  def stages(_, %{source: contest}) do
    {:ok, contest.host.stages}
  end
end
