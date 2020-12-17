defmodule JumubaseWeb.Internal.MaintenanceView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.ParticipantView, only: [full_name: 1]

  @doc """
  Lists the participants' names using a simple separator.
  """
  def list_participants(participants) do
    participants |> Enum.map(&full_name(&1)) |> Enum.join(" / ")
  end

  @doc """
  Lists the performance edit codes using a separator, and links each to the performance's detail page.
  """
  def list_performance_edit_codes(conn, performances) do
    performances
    |> Enum.map(fn p ->
      %{contest_category: %{contest: c}} = p
      link(p.edit_code, to: Routes.internal_contest_performance_path(conn, :show, c, p))
    end)
    |> Enum.intersperse(" / ")
  end
end
