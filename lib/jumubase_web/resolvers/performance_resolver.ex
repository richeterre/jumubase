defmodule JumubaseWeb.PerformanceResolver do
  alias Jumubase.Showtime.Performance
  alias Jumubase.Showtime.PerformanceFilter
  alias JumubaseWeb.Internal.PerformanceView

  def performances(%{contest_id: c_id} = args, _) do
    case Jumubase.Foundation.get_public_contest(c_id) do
      nil ->
        {:error, "No public contest found for this ID"}

      contest ->
        filter_params = args[:filter] || %{}
        filter = PerformanceFilter.from_params(filter_params)
        {:ok, Jumubase.Showtime.list_performances(contest, filter)}
    end
  end

  def category_info(_, %{source: %Performance{} = p}) do
    {:ok, PerformanceView.category_info(p)}
  end

  def appearances(_, %{source: %Performance{} = p}) do
    {:ok, PerformanceView.sorted_appearances(p)}
  end
end
