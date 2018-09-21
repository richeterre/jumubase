defmodule Jumubase.Foundation.AgeGroups do
  alias Jumubase.JumuParams

  @doc """
  Returns all possible age groups.
  """
  def all, do: ["Ia", "Ib", "II", "III", "IV", "V", "VI", "VII"]

  @doc """
  Returns the age group for the birthdate in the given season.
  """
  def calculate_age_group(%Date{} = birthdate, season) do
    lookup_age_group(birthdate, season)
  end
  @doc """
  Returns the joint age group for the birthdates in the given season,
  by using the year that the "mean birthdate" falls into.
  """
  def calculate_age_group(birthdates, season) when is_list(birthdates) do
    birthdates |> average_date |> lookup_age_group(season)
  end

  # Private helpers

  defp lookup_age_group(%Date{year: year}, season) do
    index = case JumuParams.year(season) - year do
      n when n in 0..8 -> 0
      n when n in 9..10 -> 1
      n when n in 11..12 -> 2
      n when n in 13..14 -> 3
      n when n in 15..16 -> 4
      n when n in 17..18 -> 5
      n when n in 19..21 -> 6
      n when n in 22..27 -> 7
    end

    all() |> Enum.fetch!(index)
  end

  defp average_date(dates) when is_list(dates) do
    dates
    # Convert to UNIX timestamps
    |> Enum.map(&Timex.to_unix/1)
    # Calculate average timestamp
    |> Enum.sum
    |> div(length(dates))
    # Convert back to date
    |> Timex.from_unix
    |> Timex.to_date
  end
end
