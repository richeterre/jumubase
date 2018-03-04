defmodule Jumubase.JumuParams do
  @moduledoc """
  Defines various params inherent to the Jumu institution.
  """

  @doc """
  Returns all possible user roles.
  """
  def roles do
    [
      # A "regular" user, organizing 1st-round (RW) contests
      "rw-organizer",
      # A user organizing 2nd-round (LW) contests
      "lw-organizer",
      # An outside official looking for statistics
      "inspector",
      # An omnipotent being
      "admin"
    ]
  end
end
