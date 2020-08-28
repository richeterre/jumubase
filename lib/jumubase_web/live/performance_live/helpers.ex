defmodule JumubaseWeb.PerformanceLive.Helpers do
  use Phoenix.LiveView

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
    |> Enum.find_index(&(!&1.is_valid?))
  end
end
