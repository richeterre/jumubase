defmodule JumubaseWeb.PerformanceLive.Helpers do
  import Phoenix.LiveView, only: [assign: 2]
  alias Ecto.Changeset

  def toggle_appearance_panel(socket, index) do
    new_index = if socket.assigns.expanded_appearance_index == index, do: nil, else: index
    assign(socket, expanded_appearance_index: new_index)
  end

  def toggle_piece_panel(socket, index) do
    new_index = if socket.assigns.expanded_piece_index == index, do: nil, else: index
    assign(socket, expanded_piece_index: new_index)
  end

  def handle_failed_submit(socket, changeset) do
    socket
    |> assign(changeset: changeset)
    |> expand_first_appearance_with_errors(changeset)
    |> expand_first_piece_with_errors(changeset)
  end

  # Private helpers

  defp expand_first_appearance_with_errors(socket, changeset) do
    case first_error_index(changeset, :appearances) do
      nil -> socket
      index -> assign(socket, expanded_appearance_index: index)
    end
  end

  defp expand_first_piece_with_errors(socket, changeset) do
    case first_error_index(changeset, :pieces) do
      nil -> socket
      index -> assign(socket, expanded_piece_index: index)
    end
  end

  defp first_error_index(changeset, relation_name) do
    changeset
    |> Changeset.get_change(relation_name, [])
    |> Enum.find_index(fn cs -> not cs.valid? end)
  end
end
