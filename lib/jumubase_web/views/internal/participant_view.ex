defmodule JumubaseWeb.Internal.ParticipantView do
  use JumubaseWeb, :view
  alias Jumubase.Showtime.Participant

  @doc """
  Returns the participant's full name.
  """
  def full_name(%Participant{given_name: given_name, family_name: family_name}) do
    "#{given_name} #{family_name}"
  end

  @doc """
  Returns the participant's birthdate formatted for display.
  """
  def birthdate(%Participant{birthdate: birthdate}) do
    Timex.format!(birthdate, "{YYYY}-{0M}-{0D}")
  end
end
