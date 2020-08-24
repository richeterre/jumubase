defmodule JumubaseWeb.PerformanceLive.New do
  use Phoenix.LiveView
  alias Jumubase.Foundation
  alias Jumubase.Foundation.{Contest, ContestCategory}
  alias Jumubase.Showtime
  alias Jumubase.Showtime.{Appearance, Performance, Piece}

  def render(assigns) do
    Phoenix.View.render(JumubaseWeb.PerformanceView, "live_form.html", assigns)
  end

  def mount(_params, %{"contest_id" => c_id}, socket) do
    contest = Foundation.get_contest!(c_id) |> Foundation.load_contest_categories()

    changeset =
      Showtime.build_performance(contest)
      |> Showtime.change_performance()

    {:ok,
     assign(socket,
       changeset: changeset,
       contest: contest,
       contest_category_options:
         contest.contest_categories |> Enum.map(&{&1.category.name, &1.id})
     )}
  end

  def handle_event("change", %{"performance" => attrs, "_target" => target}, socket) do
    contest = socket.assigns.contest

    changeset =
      Performance.changeset(%Performance{}, attrs, contest.round)
      |> Map.put(:action, :insert)
      |> populate_appearances(target, contest)

    {:noreply, assign(socket, changeset: changeset)}
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

  defp populate_appearances(
         %Ecto.Changeset{changes: %{contest_category_id: cc_id}} = changeset,
         ["performance", "contest_category_id"],
         %Contest{contest_categories: contest_categories}
       ) do
    case changeset |> Ecto.Changeset.get_field(:appearances, []) |> length do
      0 ->
        case Enum.find(contest_categories, &(&1.id == cc_id)) do
          %ContestCategory{category: %{type: "ensemble"}} -> append_appearances(changeset, 2)
          %ContestCategory{category: %{type: _}} -> append_appearance(changeset)
          _ -> changeset
        end

      _ ->
        changeset
    end
  end

  defp populate_appearances(changeset, _, _), do: changeset

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
