defmodule Jumubase.Showtime.Instruments do
  @moduledoc """
  A module that maps between instrument codes and their display names.
  """

  import Jumubase.Gettext

  @instruments %{
    "accordion" => gettext("Accordion"),
    "baglama" => gettext("Bağlama"),
    "bassoon" => gettext("Bassoon"),
    "bouzouki" => gettext("Bouzouki"),
    "cittern" => gettext("Cittern"),
    "clarinet" => gettext("Clarinet"),
    "cor_anglais" => gettext("Cor anglais"),
    "double_bass" => gettext("Double bass"),
    "drumset" => gettext("Drumset"),
    "e-bass" => gettext("Electric Bass"),
    "e-guitar" => gettext("Electric Guitar"),
    "euphonium" => gettext("Euphonium"),
    "flute" => gettext("Flute"),
    "french_horn" => gettext("French horn"),
    "guitar" => gettext("Guitar"),
    "harp" => gettext("Harp"),
    "harpsichord" => gettext("Harpsichord"),
    "kantele" => gettext("Kantele"),
    "keyboard" => gettext("Keyboard"),
    "mallets" => gettext("Mallets"),
    "mandola" => gettext("Mandola"),
    "mandolin" => gettext("Mandolin"),
    "mizmar" => gettext("Mizmar"),
    "ney" => gettext("Ney"),
    "oboe" => gettext("Oboe"),
    "organ" => gettext("Organ"),
    "oud" => gettext("Oud"),
    "percussion" => gettext("Percussion"),
    "piano" => gettext("Piano"),
    "qanun" => gettext("Qanun"),
    "recorder" => gettext("Recorder"),
    "saxophone" => gettext("Saxophone"),
    "tabla" => gettext("Tabla"),
    "trombone" => gettext("Trombone"),
    "trumpet" => gettext("Trumpet/Flugelhorn"),
    "tuba" => gettext("Tuba"),
    "viola" => gettext("Viola"),
    "viola_da_gamba" => gettext("Viola da gamba"),
    "violin" => gettext("Violin"),
    "violoncello" => gettext("Violoncello"),
    "vocals" => gettext("Vocals")
  }

  def all, do: @instruments

  def name(instrument) when is_binary(instrument) do
    @instruments[instrument]
  end
end
