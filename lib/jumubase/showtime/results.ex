defmodule Jumubase.Showtime.Results do

  @doc """
  Returns a mapping from point ranges to ratings, depending on round.
  """
  def ratings_for_round(0) do
    %{
      23..25 => "mit hervorragendem Erfolg teilgenommen",
      21..22 => "mit sehr gutem Erfolg teilgenommen",
      17..20 => "mit gutem Erfolg teilgenommen",
      9..16 => "mit Erfolg teilgenommen",
      0..8 => "teilgenommen",
    }
  end
  def ratings_for_round(1) do
    %{
      9..12 => "mit gutem Erfolg teilgenommen",
      5..8 => "mit Erfolg teilgenommen",
      0..4 => "teilgenommen",
    }
  end
  def ratings_for_round(2) do
    %{
      14..16 => "mit gutem Erfolg teilgenommen",
      11..13 => "mit Erfolg teilgenommen",
      0..10 => "teilgenommen",
    }
  end

  @doc """
  Returns a mapping from point ranges to prizes, depending on round.
  """
  def prizes_for_round(0), do: %{}
  def prizes_for_round(1) do
    %{
      21..25 => "1. Preis",
      17..20 => "2. Preis",
      13..16 => "3. Preis",
    }
  end
  def prizes_for_round(2) do
    %{
      23..25 => "1. Preis",
      20..22 => "2. Preis",
      17..19 => "3. Preis",
    }
  end

  @doc """
  Returns the prize resulting from the points in the given round, or nil if no prize is awarded.
  """
  def get_prize(points, round) do
    prizes_for_round(round)
    |> Enum.find_value(fn {point_range, name} ->
      if points in point_range, do: name, else: false
    end)
  end
end
