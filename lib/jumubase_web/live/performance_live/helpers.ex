defmodule JumubaseWeb.PerformanceLive.Helpers do
  import Phoenix.LiveView, only: [assign: 2]
  alias Ecto.Changeset
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Contest

  @doc """
  Returns predecessor host options based on the contest, suitable for form use.
  """
  def predecessor_host_options(%Contest{round: 2, grouping: grouping}) do
    Foundation.list_hosts_by_grouping(grouping)
    |> Enum.map(&{&1.name, &1.id})
  end

  def predecessor_host_options(%Contest{}), do: []

  @doc """
  Returns whether the changeset contains a contest category that requires
  a concept document, meaning that we need to display a form field for it.
  """
  def needs_concept_document_field?(changeset, %Contest{} = contest) do
    with cc_id <- Ecto.Changeset.get_field(changeset, :contest_category_id),
         cc when not is_nil(cc) <- Enum.find(contest.contest_categories, &(&1.id == cc_id)) do
      cc.requires_concept_document
    else
      _ ->
        false
    end
  end

  def parse_id(id) when is_binary(id) do
    String.to_integer(id)
  end

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
