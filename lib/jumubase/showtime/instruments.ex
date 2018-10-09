defmodule Jumubase.Showtime.Instruments do
  @moduledoc """
  A module that maps between instrument codes and their display names.
  """

  import Jumubase.Gettext

  @instruments %{
    "bassoon" => dgettext("instruments", "Bassoon"),
    "clarinet" => dgettext("instruments", "Clarinet"),
    "drumset" => dgettext("instruments", "Drumset"),
    "e-bass" => dgettext("instruments", "Electric Bass"),
    "e-guitar" => dgettext("instruments", "Electric Guitar"),
    "guitar" => dgettext("instruments", "Guitar"),
    "oboe" => dgettext("instruments", "Oboe"),
    "piano" => dgettext("instruments", "Piano"),
    "saxophone" => dgettext("instruments", "Saxophone"),
    "vocals" => dgettext("instruments", "Vocals"),
  }

  def all, do: @instruments

  def name(instrument) when is_binary(instrument) do
    @instruments[instrument]
  end
end
