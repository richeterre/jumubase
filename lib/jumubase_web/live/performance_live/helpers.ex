defmodule JumubaseWeb.PerformanceLive.Helpers do
  import Phoenix.LiveView, only: [assign: 2]
  alias Ecto.Changeset
  alias Jumubase.Foundation
  alias Jumubase.Showtime
  alias Jumubase.Showtime.{Appearance, Performance, Piece}

  def prepare_new(%{"contest_id" => c_id, "submit_title" => submit_title}, socket, opts \\ []) do
    contest = Foundation.get_contest!(c_id) |> Foundation.load_contest_categories()

    kimu_contest =
      if opts[:include_kimu_contest],
        do: Foundation.get_matching_kimu_contest(contest),
        else: nil

    changeset =
      %Performance{}
      |> Showtime.change_performance()
      |> append_appearance()
      |> append_piece()

    {:ok,
     assign(socket,
       changeset: changeset,
       contest: contest,
       kimu_contest: kimu_contest,
       expanded_appearance_index: nil,
       expanded_piece_index: nil,
       submit_title: submit_title
     )}
  end

  def change_new(socket, attrs) do
    contest = socket.assigns.contest

    changeset =
      Performance.changeset(%Performance{}, attrs, contest.round)
      |> Map.put(:action, :insert)

    assign(socket, changeset: changeset)
  end

  def add_appearance(socket) do
    changeset = socket.assigns.changeset
    index = get_appearance_count(changeset)

    assign(socket,
      changeset: append_appearance(changeset),
      expanded_appearance_index: socket.assigns.expanded_appearance_index || index
    )
  end

  def remove_appearance(socket, index) do
    changeset = remove_item(socket.assigns.changeset, :appearances, index)
    assign(socket, changeset: changeset)
  end

  def add_piece(socket) do
    changeset = socket.assigns.changeset
    index = get_piece_count(changeset)

    assign(socket,
      changeset: append_piece(changeset),
      expanded_piece_index: socket.assigns.expanded_piece_index || index
    )
  end

  def remove_piece(socket, index) do
    changeset = remove_item(socket.assigns.changeset, :pieces, index)
    assign(socket, changeset: changeset)
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

  defp get_appearance_count(cs), do: get_existing_items(cs, :appearances) |> length()
  defp append_appearance(cs), do: append_item(cs, :appearances, %Appearance{})

  defp get_piece_count(cs), do: get_existing_items(cs, :pieces) |> length()
  defp append_piece(cs), do: append_item(cs, :pieces, %Piece{})

  defp append_item(cs, field, item) do
    items = get_existing_items(cs, field) ++ [item]
    Changeset.put_assoc(cs, field, items)
  end

  defp remove_item(cs, field, index) do
    items = get_existing_items(cs, field) |> List.delete_at(index)
    Changeset.put_assoc(cs, field, items)
  end

  defp get_existing_items(cs, field) do
    Map.get(cs.changes, field, [])
  end

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
