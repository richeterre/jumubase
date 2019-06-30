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

        performances =
          Showtime.scheduled_performances(contest, filter)
          |> Showtime.load_predecessor_contests()

        {:ok, performances}
    end
  end

  def performance(%{id: id}, _) do
    case Showtime.get_public_performance(id) do
      nil -> {:error, "No public performance found for this ID"}
      performance -> {:ok, performance |> Showtime.load_predecessor_contest()}
    end
  end

  def category_info(_, %{source: %Performance{} = p}) do
    {:ok, PerformanceView.category_info(p)}
  end

  def predecessor_host(_, %{source: %Performance{} = p}) do
    case p.predecessor_contest do
      nil -> {:ok, nil}
      contest -> {:ok, contest.host}
    end
  end

  def appearances(_, %{source: %Performance{} = p}) do
    {:ok, PerformanceView.sorted_appearances(p)}
  end
end
