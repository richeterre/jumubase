defmodule JumubaseWeb.PerformanceLive.New do
  use Phoenix.LiveView
  import Jumubase.Gettext
  import JumubaseWeb.PerformanceLive.Helpers
  alias Ecto.Changeset
  alias Jumubase.Foundation
  alias Jumubase.Showtime
  alias Jumubase.Showtime.{Appearance, Performance, Piece}
  alias JumubaseWeb.Router.Helpers, as: Routes

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
       expanded_appearance_index: nil,
       expanded_piece_index: nil
     )}
  end

  def handle_event("change", %{"performance" => attrs}, socket) do
    contest = socket.assigns.contest

    changeset =
      Performance.changeset(%Performance{}, attrs, contest.round)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("add-appearance", _, socket) do
    {:noreply, assign(socket, changeset: append_appearance(socket.assigns.changeset))}
  end

  def handle_event("remove-appearance", %{"index" => index}, socket) do
    changeset = remove_appearance(socket.assigns.changeset, String.to_integer(index))
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("toggle-appearance-panel", %{"index" => index}, socket) do
    index = String.to_integer(index)

    new_index = if socket.assigns.expanded_appearance_index == index, do: nil, else: index
    {:noreply, assign(socket, expanded_appearance_index: new_index)}
  end

  def handle_event("add-piece", _, socket) do
    {:noreply, assign(socket, changeset: append_piece(socket.assigns.changeset))}
  end

  def handle_event("remove-piece", %{"index" => index}, socket) do
    changeset = remove_piece(socket.assigns.changeset, String.to_integer(index))
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("toggle-piece-panel", %{"index" => index}, socket) do
    index = String.to_integer(index)

    new_index = if socket.assigns.expanded_piece_index == index, do: nil, else: index
    {:noreply, assign(socket, expanded_piece_index: new_index)}
  end

  def handle_event("submit", %{"performance" => attrs}, socket) do
    contest = socket.assigns.contest

    case Showtime.create_performance(contest, attrs) do
      {:ok, %Performance{edit_code: edit_code}} ->
        {:noreply,
         socket
         |> put_flash(:success, registration_success_message(edit_code))
         |> redirect(to: Routes.page_path(socket, :home))}

      {:error, changeset} ->
        {:noreply, handle_failed_submit(socket, changeset)}
    end
  end

  # Private helpers

  defp append_appearance(changeset), do: append_item(changeset, :appearances, %Appearance{})
  defp remove_appearance(changeset, index), do: remove_item(changeset, :appearances, index)

  defp append_piece(changeset), do: append_item(changeset, :pieces, %Piece{})
  defp remove_piece(changeset, index), do: remove_item(changeset, :pieces, index)

  defp append_item(changeset, field, item) do
    items = get_existing_items(changeset, field) ++ [item]
    changeset |> Changeset.put_assoc(field, items)
  end

  defp remove_item(changeset, field, index) do
    items = get_existing_items(changeset, field) |> List.delete_at(index)
    changeset |> Changeset.put_assoc(field, items)
  end

  defp get_existing_items(changeset, field) do
    Map.get(changeset.changes, field, [])
  end

  defp registration_success_message(edit_code) do
    success_msg = gettext("We received your registration!")

    edit_msg =
      gettext("You can still change it later using the edit code %{edit_code}.",
        edit_code: edit_code
      )

    "#{success_msg} #{edit_msg}"
  end
end
