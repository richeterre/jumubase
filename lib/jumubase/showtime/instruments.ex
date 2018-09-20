defmodule Jumubase.Showtime.Instruments do
  @moduledoc """
  A module that maps between instrument codes and their display names.
  """

  import Jumubase.Gettext

  @instruments %{
    "bassoon" => gettext("Bassoon"),
    "clarinet" => gettext("Clarinet"),
    "drumset" => gettext("Drumset"),
    "e-bass" => gettext("Electric Bass"),
    "e-guitar" => gettext("Electric Guitar"),
    "guitar" => gettext("Guitar"),
    "oboe" => gettext("Oboe"),
    "piano" => gettext("Piano"),
    "saxophone" => gettext("Saxophone"),
    "vocals" => gettext("Vocals"),
  }

  def all, do: @instruments

  def name(instrument) when is_binary(instrument) do
    @instruments[instrument]
  end
end
