defmodule Jumubase.Showtime.Results do
  alias Jumubase.Foundation.AgeGroups
  alias Jumubase.Showtime.{Appearance, Performance}

  @doc """
  Returns a mapping from point ranges to ratings, depending on round.
  """
  def ratings_for_round(0) do
    %{
      (23..25) => "mit hervorragendem Erfolg teilgenommen",
      (21..22) => "mit sehr gutem Erfolg teilgenommen",
      (17..20) => "mit gutem Erfolg teilgenommen",
      (9..16) => "mit Erfolg teilgenommen",
      (0..8) => "teilgenommen"
    }
  end

  def ratings_for_round(1) do
    %{
      (9..12) => "mit gutem Erfolg teilgenommen",
      (5..8) => "mit Erfolg teilgenommen",
      (0..4) => "teilgenommen"
    }
  end

  def ratings_for_round(2) do
    %{
      (14..16) => "mit gutem Erfolg teilgenommen",
      (11..13) => "mit Erfolg teilgenommen",
      (0..10) => "teilgenommen"
    }
  end

  @doc """
  Returns a mapping from point ranges to prizes, depending on round.
  """
  def prizes_for_round(0), do: %{}

  def prizes_for_round(1) do
    %{
      (21..25) => "1. Preis",
      (17..20) => "2. Preis",
      (13..16) => "3. Preis"
    }
  end

  def prizes_for_round(2) do
    %{
      (23..25) => "1. Preis",
      (20..22) => "2. Preis",
      (17..19) => "3. Preis"
    }
  end

  @doc """
  Returns the prize resulting from the points in the given round, or nil if no prize is awarded.
  """
  def get_prize(points, round) do
    prizes_for_round(round) |> lookup(points)
  end

  @doc """
  Returns the rating resulting from the points in the given round.
  """
  def get_rating(points, round) do
    ratings_for_round(round) |> lookup(points)
  end

  def advances?(%Performance{contest_category: cc} = p) do
    %{
      min_advancing_age_group: min_ag,
      max_advancing_age_group: max_ag
    } = cc

    # Check age group range, then decide based on first non-accompanist
    Enum.all?([min_ag, max_ag]) and
      AgeGroups.in_range?(p.age_group, min_ag, max_ag) and
      Performance.non_accompanists(p) |> hd |> may_advance?
  end

  @doc """
  Returns whether an appearance advances, using data from its parent performance.
  """
  def advances?(%Appearance{performance_id: id} = a, %Performance{id: id} = p) do
    may_advance?(a) and advances?(p)
  end

  @doc """
  Returns whether an appearance might be ineligible for the next round,
  (example: pop accompanist groups) and should be checked by a human.
  """
  def needs_eligibility_check?(
        %Appearance{performance_id: id, role: "accompanist", points: points},
        %Performance{id: id} = p,
        round
      ) do
    advances?(p) and
      has_acc_group?(p) and
      (round > 1 or points not in advancing_point_range())
  end

  def needs_eligibility_check?(_appearance, _performance, _round), do: false

  # Private helpers

  defp advancing_point_range, do: 23..25

  defp may_advance?(%Appearance{role: "accompanist"}), do: false

  defp may_advance?(%Appearance{points: points}) do
    points in advancing_point_range()
  end

  defp lookup(point_mapping, points) do
    Enum.find_value(point_mapping, fn {point_range, result} ->
      if points in point_range, do: result, else: false
    end)
  end

  defp has_acc_group?(p) do
    p |> Performance.accompanists() |> length > 1
  end
end
