defmodule Jumubase.Foundation.AgeGroups do
  alias Jumubase.JumuParams

  @min_age 4
  @max_age 27

  @doc """
  Returns the range of allowed participant birthyears for the given season.
  """
  def birthyear_range(season) do
    year = JumuParams.year(season)
    (year - @min_age)..(year - @max_age)
  end

  @doc """
  Returns all possible age groups.
  """
  def all, do: ["Ia", "Ib", "II", "III", "IV", "V", "VI", "VII"]

  @doc """
  Returns the age group for the birthdate(s) in the given season.
  If multiple birthdates are given, it uses the year that the "mean birthdate" falls into.
  """
  def calculate_age_group(%Date{} = birthdate, season) do
    lookup_age_group(birthdate, season)
  end

  def calculate_age_group(birthdates, season) when is_list(birthdates) do
    birthdates |> average_date |> lookup_age_group(season)
  end

  def in_range?(ag, min_ag, max_ag) do
    [ag_index, min_index, max_index] = [ag, min_ag, max_ag] |> Enum.map(&find_index/1)
    ag_index in min_index..max_index
  end

  # Private helpers

  defp lookup_age_group(%Date{year: year}, season) do
    index =
      case JumuParams.year(season) - year do
        n when n in @min_age..8 -> 0
        n when n in 9..10 -> 1
        n when n in 11..12 -> 2
        n when n in 13..14 -> 3
        n when n in 15..16 -> 4
        n when n in 17..18 -> 5
        n when n in 19..21 -> 6
        n when n in 22..@max_age -> 7
      end

    all() |> Enum.fetch!(index)
  end

  defp average_date(dates) when is_list(dates) do
    dates
    # Convert to UNIX timestamps
    |> Enum.map(&Timex.to_unix/1)
    # Calculate average timestamp
    |> Enum.sum()
    |> div(length(dates))
    # Convert back to date
    |> Timex.from_unix()
    |> Timex.to_date()
  end

  defp find_index(age_group) do
    all() |> Enum.find_index(&(&1 == age_group))
  end
end
