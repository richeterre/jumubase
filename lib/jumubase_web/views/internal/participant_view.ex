defmodule JumubaseWeb.Internal.ParticipantView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  alias Jumubase.Showtime.Participant
  alias JumubaseWeb.Internal.PerformanceView

  @doc """
  Returns the participant's full name.
  """
  def full_name(%Participant{given_name: given_name, family_name: family_name}) do
    "#{given_name} #{family_name}"
  end
end
