defmodule JumubaseWeb.PerformanceLive.New do
  use Phoenix.LiveView
  alias Jumubase.Foundation
  alias Jumubase.Showtime
  alias Jumubase.Showtime.{Appearance, Performance, Piece}

  def render(assigns) do
    Phoenix.View.render(JumubaseWeb.PerformanceView, "live_form.html", assigns)
  end

  def mount(_params, %{"contest_id" => c_id}, socket) do
    contest = Foundation.get_contest!(c_id) |> Foundation.load_contest_categories()

    changeset =
      %Performance{}
      |> Showtime.change_performance()
      |> append_appearance()
      |> append_piece()

    {:ok,
     assign(socket,
       changeset: changeset,
       contest: contest,
       contest_category_options:
         contest.contest_categories |> Enum.map(&{&1.category.name, &1.id}),
       expanded_appearance_index: nil,
       expanded_piece_index: nil
     )}
  end

  def handle_event("change", %{"performance" => attrs, "_target" => target}, socket) do
    contest = socket.assigns.contest

    changeset =
      Performance.changeset(%Performance{}, attrs, contest.round)
      |> Map.put(:action, :insert)

    # Keep appearance or piece panel open while user is editing its data
    case target do
      ["performance", "appearances", a_index | _] ->
        a_index = String.to_integer(a_index)
        {:noreply, assign(socket, changeset: changeset, expanded_appearance_index: a_index)}

      ["performance", "pieces", pc_index | _] ->
        pc_index = String.to_integer(pc_index)
        {:noreply, assign(socket, changeset: changeset, expanded_piece_index: pc_index)}

      _ ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("add-appearance", _, socket) do
    changeset = socket.assigns.changeset |> append_appearance()
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("remove-appearance", %{"index" => index}, socket) do
    changeset = socket.assigns.changeset |> remove_appearance(String.to_integer(index))
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("add-piece", _, socket) do
    changeset = socket.assigns.changeset |> append_piece()
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("remove-piece", %{"index" => index}, socket) do
    changeset = socket.assigns.changeset |> remove_piece(String.to_integer(index))
    {:noreply, assign(socket, changeset: changeset)}
  end

  # Private helpers

  defp append_appearance(changeset) do
    append_appearances(changeset, 1)
  end

  defp append_appearances(changeset, count) do
    existing_appearances = Map.get(changeset.changes, :appearances, [])

    appearances =
      existing_appearances
      |> Enum.concat(List.duplicate(%Appearance{}, count))

    changeset
    |> Ecto.Changeset.put_assoc(:appearances, appearances)
  end

  defp remove_appearance(changeset, index) do
    existing_appearances = Map.get(changeset.changes, :appearances, [])
    appearances = existing_appearances |> List.delete_at(index)
    changeset |> Ecto.Changeset.put_assoc(:appearances, appearances)
  end

  defp append_piece(changeset) do
    existing_pieces = Map.get(changeset.changes, :pieces, [])
    pieces = existing_pieces |> Enum.concat([%Piece{}])
    changeset |> Ecto.Changeset.put_assoc(:pieces, pieces)
  end

  defp remove_piece(changeset, index) do
    existing_pieces = Map.get(changeset.changes, :pieces, [])
    pieces = existing_pieces |> List.delete_at(index)
    changeset |> Ecto.Changeset.put_assoc(:pieces, pieces)
  end
end
