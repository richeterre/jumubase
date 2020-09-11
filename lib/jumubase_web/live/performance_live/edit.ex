defmodule JumubaseWeb.PerformanceLive.Edit do
  use Phoenix.LiveView
  import Jumubase.Gettext
  import JumubaseWeb.PerformanceController, only: [normalize_params: 1]
  import JumubaseWeb.PerformanceLive.Helpers
  alias Ecto.Changeset
  alias Jumubase.Foundation
  alias Jumubase.Showtime
  alias Jumubase.Showtime.{Appearance, Performance, Piece}
  alias JumubaseWeb.Router.Helpers, as: Routes

  def render(assigns) do
    Phoenix.View.render(JumubaseWeb.PerformanceView, "live_form.html", assigns)
  end

  def mount(_params, %{"contest_id" => c_id, "performance_id" => p_id}, socket) do
    contest = Foundation.get_contest!(c_id) |> Foundation.load_contest_categories()
    performance = Showtime.get_performance!(contest, p_id)

    {:ok,
     assign(socket,
       changeset: Showtime.change_performance(performance),
       contest: contest,
       performance: performance,
       expanded_appearance_index: nil,
       expanded_piece_index: nil
     )}
  end

  def handle_event("change", %{"performance" => params}, socket) do
    contest = socket.assigns.contest
    performance = socket.assigns.performance

    changeset =
      Performance.changeset(performance, params, contest.round)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("add-appearance", _, socket) do
    {changeset, index} = add_item(socket.assigns.changeset, :appearances, %Appearance{})

    {:noreply,
     assign(socket,
       changeset: changeset,
       expanded_appearance_index: socket.assigns.expanded_appearance_index || index
     )}
  end

  def handle_event("remove-appearance", %{"index" => index}, socket) do
    changeset = remove_item(socket.assigns.changeset, :appearances, parse_id(index))
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("toggle-appearance-panel", %{"index" => index}, socket) do
    {:noreply, toggle_appearance_panel(socket, parse_id(index))}
  end

  def handle_event("add-piece", _, socket) do
    {changeset, index} = add_item(socket.assigns.changeset, :pieces, %Piece{})

    {:noreply,
     assign(socket,
       changeset: changeset,
       expanded_piece_index: socket.assigns.expanded_piece_index || index
     )}
  end

  def handle_event("remove-piece", %{"index" => index}, socket) do
    changeset = remove_item(socket.assigns.changeset, :pieces, parse_id(index))
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("toggle-piece-panel", %{"index" => index}, socket) do
    {:noreply, toggle_piece_panel(socket, parse_id(index))}
  end

  def handle_event("submit", %{"performance" => params}, socket) do
    contest = socket.assigns.contest
    performance = socket.assigns.performance

    params = normalize_params(params)

    case Showtime.update_performance(contest, performance, params) do
      {:ok, %Performance{}} ->
        {:noreply,
         socket
         |> put_flash(:success, gettext("Your changes to the registration were saved."))
         |> redirect(to: Routes.page_path(socket, :home))}

      {:error, changeset} ->
        {:noreply, handle_failed_submit(socket, changeset)}
    end
  end

  # Private helpers

  defp add_item(changeset, field_name, item) do
    existing =
      changeset
      |> Changeset.get_field(field_name, [])
      |> exclude_obsolete()

    changeset = changeset |> Changeset.put_assoc(field_name, existing ++ [item])
    {changeset, length(existing)}
  end

  defp remove_item(changeset, field_name, index) do
    remaining =
      changeset
      |> Changeset.get_field(field_name, [])
      |> exclude_obsolete()
      |> List.delete_at(index)

    Changeset.put_assoc(changeset, field_name, remaining)
  end

  defp exclude_obsolete(records_or_changesets) do
    records_or_changesets
    |> Enum.filter(fn
      %Changeset{action: action} -> action in [:insert, :update]
      _ -> true
    end)
  end
end
