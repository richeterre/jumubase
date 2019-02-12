defmodule JumubaseWeb.Internal.MaintenanceView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.ParticipantView, only: [full_name: 1]

  @doc """
  Lists the participants' names using a simple separator.
  """
  def list_participants(participants) do
    participants |> Enum.map(&full_name(&1)) |> Enum.join(" / ")
  end
end
