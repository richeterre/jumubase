defmodule JumubaseWeb.ShowtimeResolver do
  alias Jumubase.Foundation
  alias Jumubase.Showtime
  alias Jumubase.Showtime.{Appearance, Performance, Piece}
  alias Jumubase.Showtime.PerformanceFilter
  alias Jumubase.Showtime.Results
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
          |> Showtime.load_predecessor_hosts()

        {:ok, performances}
    end
  end

  def performance(_, %{id: id}, _) do
    case Showtime.get_public_performance(id) do
      nil -> {:error, "No public performance found for this ID"}
      performance -> {:ok, performance |> Showtime.load_predecessor_host()}
    end
  end

  def stage_date(%Performance{} = p, _, _) do
    {:ok, NaiveDateTime.to_date(p.stage_time)}
  end

  def stage_time(%Performance{} = p, _, _) do
    {:ok, NaiveDateTime.to_time(p.stage_time)}
  end

  def category_name(%Performance{} = p, _, _) do
    {:ok, PerformanceView.category_name(p)}
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

  def accompanist?(%Appearance{} = a, _, _) do
    {:ok, Appearance.accompanist?(a)}
  end

  def result(%Performance{} = p, %Appearance{} = a, _) do
    if !!a.points and p.results_public do
      %{round: round} = p.contest_category.contest

      {:ok,
       %{
         points: a.points,
         prize: Results.get_prize(a.points, round),
         advances: Results.advances?(a, p)
       }}
    else
      {:ok, nil}
    end
  end

  def person_info(%Piece{} = pc, _, _) do
    {:ok, PieceView.person_info(pc)}
  end
end
