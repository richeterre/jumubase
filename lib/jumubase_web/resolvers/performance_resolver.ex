defmodule JumubaseWeb.PerformanceResolver do
  alias Jumubase.Showtime.Performance
  alias Jumubase.Showtime.PerformanceFilter
  alias JumubaseWeb.Internal.PerformanceView
  alias JumubaseWeb.Internal.AppearanceView

  def performances(%{contest_id: c_id, filter: filter_params}, _) do
    case Jumubase.Foundation.get_public_contest(c_id) do
      nil ->
        {:error, "No public contest found for this ID"}

      contest ->
        filter = PerformanceFilter.from_params(filter_params)
        {:ok, Jumubase.Showtime.list_performances(contest, filter)}
    end
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
