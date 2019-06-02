defmodule JumubaseWeb.PerformanceResolver do
  alias Jumubase.Showtime.Performance
  alias Jumubase.Showtime.PerformanceFilter
  alias JumubaseWeb.Internal.PerformanceView
  alias JumubaseWeb.Internal.AppearanceView

  def performances(%{contest_id: c_id, filter: filter_params}, _) do
    contest = Jumubase.Foundation.get_contest!(c_id)
    filter = PerformanceFilter.from_params(filter_params)
    {:ok, Jumubase.Showtime.list_performances(contest, filter)}
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
