defmodule JumubaseWeb.PerformanceResolver do
  alias Jumubase.Showtime.Performance
  alias JumubaseWeb.Internal.PerformanceView
  alias JumubaseWeb.Internal.AppearanceView

  def performances(%{contest_id: c_id}, _) do
    contest = Jumubase.Foundation.get_contest!(c_id)
    {:ok, Jumubase.Showtime.list_performances(contest)}
  end

  def stage_time(_, %{source: %Performance{} = p}) do
    {:ok, PerformanceView.stage_time(p)}
  end

  def category_info(_, %{source: %Performance{} = p}) do
    {:ok, PerformanceView.category_info(p)}
  end

  def appearances(_, %{source: %Performance{} = p}) do
    {:ok, Enum.map(p.appearances, fn a -> AppearanceView.appearance_info(a) end)}
  end
end
