defmodule JumubaseWeb.Internal.AppearanceView do
  use JumubaseWeb, :view
  alias Jumubase.Showtime.Appearance

  @doc """
  Returns a display name for the instrument.
  """
  def instrument_name(instrument) do
    Jumubase.Showtime.Instruments.name(instrument)
  end
end
