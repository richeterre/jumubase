defmodule JumubaseWeb.PerformanceResolver do
  alias Jumubase.Foundation
  alias Jumubase.Showtime
  alias Jumubase.Showtime.Performance
  alias Jumubase.Showtime.PerformanceFilter
  alias JumubaseWeb.Internal.PerformanceView

  def performances(%{contest_id: c_id} = args, _) do
    case Foundation.get_public_contest(c_id) do
      nil ->
        {:error, "No public contest found for this ID"}

      contest ->
        filter_params = args[:filter] || %{}
        filter = PerformanceFilter.from_params(filter_params)
        {:ok, Showtime.scheduled_performances(contest, filter)}
    end
  end

  def performance(%{id: id}, _) do
    case Showtime.get_public_performance(id) do
      nil -> {:error, "No public performance found for this ID"}
      performance -> {:ok, performance}
    end
  end

  def category_info(_, %{source: %Performance{} = p}) do
    {:ok, PerformanceView.category_info(p)}
  end

  def appearances(_, %{source: %Performance{} = p}) do
    {:ok, PerformanceView.sorted_appearances(p)}
  end
end
