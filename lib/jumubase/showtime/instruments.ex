defmodule Jumubase.Showtime.Instruments do
  @moduledoc """
  A module that maps between instrument codes and their display names.
  """

  import Jumubase.Gettext

  @instruments %{
    "accordion" => dgettext("instruments", "Accordion"),
    "bassoon" => dgettext("instruments", "Bassoon"),
    "cittern" => dgettext("instruments", "Cittern"),
    "clarinet" => dgettext("instruments", "Clarinet"),
    "cor_anglais" => dgettext("instruments", "Cor anglais"),
    "double_bass" => dgettext("instruments", "Double bass"),
    "drumset" => dgettext("instruments", "Drumset"),
    "e-bass" => dgettext("instruments", "Electric Bass"),
    "e-guitar" => dgettext("instruments", "Electric Guitar"),
    "euphonium" => dgettext("instruments", "Euphonium"),
    "flute" => dgettext("instruments", "Flute"),
    "french_horn" => dgettext("instruments", "French horn"),
    "guitar" => dgettext("instruments", "Guitar"),
    "harp" => dgettext("instruments", "Harp"),
    "harpsichord" => dgettext("instruments", "Harpsichord"),
    "kantele" => dgettext("instruments", "Kantele"),
    "keyboard" => dgettext("instruments", "Keyboard"),
    "mallets" => dgettext("instruments", "Mallets"),
    "mandola" => dgettext("instruments", "Mandola"),
    "mandolin" => dgettext("instruments", "Mandolin"),
    "oboe" => dgettext("instruments", "Oboe"),
    "organ" => dgettext("instruments", "Organ"),
    "percussion" => dgettext("instruments", "Percussion"),
    "piano" => dgettext("instruments", "Piano"),
    "recorder" => dgettext("instruments", "Recorder"),
    "saxophone" => dgettext("instruments", "Saxophone"),
    "trombone" => dgettext("instruments", "Trombone"),
    "trumpet" => dgettext("instruments", "Trumpet/Flugelhorn"),
    "tuba" => dgettext("instruments", "Tuba"),
    "viola" => dgettext("instruments", "Viola"),
    "viola_da_gamba" => dgettext("instruments", "Viola da gamba"),
    "violin" => dgettext("instruments", "Violin"),
    "violoncello" => dgettext("instruments", "Violoncello"),
    "vocals" => dgettext("instruments", "Vocals"),
  }

  def all, do: @instruments

  def name(instrument) when is_binary(instrument) do
    @instruments[instrument]
  end
end
