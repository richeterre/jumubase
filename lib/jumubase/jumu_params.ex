defmodule Jumubase.JumuParams do
  import Jumubase.Gettext

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
  Returns the season for a given year.
  """
  def season(year) do
    year - year(0)
  end

  @doc """
  Returns the available competition rounds.
  """
  def rounds do
    # Round 0 is for Kimu contests
    0..2
  end

  @doc """
  Returns the available groupings of hosts & contests.
  """
  def groupings do
    ~w(1 2 3)
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
      # A user who can view, but not change or delete anything
      "observer",
      # An omnipotent being
      "admin"
    ]
  end

  @doc """
  Returns all possible category genres.
  """
  def genres do
    ["classical", "popular", "kimu"]
  end

  @doc """
  Returns all possible category types.
  """
  def category_types do
    ["solo", "ensemble", "solo_or_ensemble"]
  end

  @doc """
  Returns all possible category groups.
  """
  def category_groups do
    ~w(
      kimu piano strings wind plucked classical_vocals accordion
      harp organ percussion mixed_lineups pop_vocals pop_instrumental
    )
  end

  @doc """
  Returns all possible participant roles.
  """
  def participant_roles do
    ["soloist", "accompanist", "ensemblist"]
  end

  @doc """
  Returns all possible piece epochs.
  """
  def epochs do
    ~w(trad a b c d e f)
  end

  @doc """
  Returns a description for the given epoch.
  """
  def epoch_description(epoch) do
    case epoch do
      "trad" -> dgettext("epochs", "Traditional / Folk Music")
      "a" -> dgettext("epochs", "Renaissance, Early Baroque")
      "b" -> dgettext("epochs", "Baroque")
      "c" -> dgettext("epochs", "Early Classical, Classical")
      "d" -> dgettext("epochs", "Romantic, Impressionist")
      "e" -> dgettext("epochs", "Modern Classical, Jazz, Pop")
      "f" -> dgettext("epochs", "Neue Musik")
    end
  end

  @doc """
  Returns the range of possible point values.
  """
  def points, do: 0..25

  @doc """
  Returns the range of points required to advance to the next round.
  """
  def advancing_point_range, do: 23..25
end
