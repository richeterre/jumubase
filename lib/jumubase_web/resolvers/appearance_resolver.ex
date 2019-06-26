defmodule JumubaseWeb.AppearanceResolver do
  alias Jumubase.Showtime.Appearance
  alias JumubaseWeb.Internal.{AppearanceView, ParticipantView}

  def participant_name(_, %{source: %Appearance{} = a}) do
    {:ok, ParticipantView.full_name(a.participant)}
  end

  def instrument_name(_, %{source: %Appearance{} = a}) do
    {:ok, AppearanceView.instrument_name(a.instrument)}
  end
end
