defmodule Jumubase.JumuParams do
  @moduledoc """
  Defines various params inherent to the Jumu institution.
  """

  @doc """
  Returns all possible user roles.
  """
  def roles do
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
end
