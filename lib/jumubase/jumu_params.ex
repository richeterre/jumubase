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
  Returns the available competition rounds.
  """
  def rounds do
    0..2 # Round 0 is for Kimu contests
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
      harp organ percussion special_lineups pop_vocals pop_instrumental
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
    ~w(a b c d e f)
  end

  @doc """
  Returns a description for the given epoch.
  """
  def epoch_description(epoch) do
    case epoch do
      "a" -> dgettext("epochs", "Renaissance, Early Baroque")
      "b" -> dgettext("epochs", "Baroque")
      "c" -> dgettext("epochs", "Early Classical, Classical")
      "d" -> dgettext("epochs", "Romantic, Impressionist")
      "e" -> dgettext("epochs", "Modern Classical, Jazz, Pop")
      "f" -> dgettext("epochs", "Neue Musik")
    end
  end
end
