defmodule Jumubase.JumuParams do
  @moduledoc """
  Defines various params inherent to the Jumu institution.
  """

  @doc """
  Returns the year for a given season.
  """
  def year(season) do
    1963 + season
  end

  @doc """
  Returns the available competition rounds.
  """
  def rounds do
    1..2
  end

  @doc """
  Returns all possible user roles.
  """
  def user_roles do
    [
      # A "regular" user who organizes contests (typically RW) locally
      "local-organizer",
      # A user organizing LW (2nd round) contests in various countries
      "global-organizer",
      # An outside official looking for statistics
      "inspector",
      # An omnipotent being
      "admin"
    ]
  end

  @doc """
  Returns all possible category genres.
  """
  def genres do
    ["classical", "popular"]
  end

  @doc """
  Returns all possible category types.
  """
  def category_types do
    ["solo", "ensemble"]
  end

  @doc """
  Returns all possible participant roles.
  """
  def participant_roles do
    ["soloist", "accompanist", "ensemblist"]
  end
end
