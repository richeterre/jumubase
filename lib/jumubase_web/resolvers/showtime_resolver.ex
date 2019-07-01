defmodule JumubaseWeb.ShowtimeResolver do
  alias Jumubase.Foundation
  alias Jumubase.Showtime
  alias Jumubase.Showtime.{Appearance, Performance, Piece}
  alias Jumubase.Showtime.PerformanceFilter
  alias JumubaseWeb.Internal.{AppearanceView, ParticipantView, PerformanceView, PieceView}

  def performances(_, %{contest_id: c_id} = args, _) do
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

  def performance(_, %{id: id}, _) do
    case Showtime.get_public_performance(id) do
      nil -> {:error, "No public performance found for this ID"}
      performance -> {:ok, performance |> Showtime.load_predecessor_contest()}
    end
  end

  def category_info(%Performance{} = p, _, _) do
    {:ok, PerformanceView.category_info(p)}
  end

  def predecessor_host(%Performance{} = p, _, _) do
    case p.predecessor_contest do
      nil -> {:ok, nil}
      contest -> {:ok, contest.host}
    end
  end

  def appearances(%Performance{} = p, _, _) do
    {:ok, PerformanceView.sorted_appearances(p)}
  end

  def participant_name(%Appearance{} = a, _, _) do
    {:ok, ParticipantView.full_name(a.participant)}
  end

  def instrument_name(%Appearance{} = a, _, _) do
    {:ok, AppearanceView.instrument_name(a.instrument)}
  end

  def result(%Performance{} = p, %Appearance{} = a, _) do
    if !!a.points and p.results_public do
      {:ok, %{points: a.points}}
    else
      {:ok, nil}
    end
  end

  def person_info(%Piece{} = pc, _, _) do
    {:ok, PieceView.person_info(pc)}
  end
end
