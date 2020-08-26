defmodule JumubaseWeb.PerformanceLive.Edit do
  use Phoenix.LiveView
  import Jumubase.Gettext
  import JumubaseWeb.PerformanceController, only: [normalize_params: 1]
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

  def handle_event("change", %{"performance" => params, "_target" => target}, socket) do
    contest = socket.assigns.contest
    performance = socket.assigns.performance

    changeset =
      Performance.changeset(performance, params, contest.round)
      |> Map.put(:action, :update)

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
    changeset = add_item(socket.assigns.changeset, :appearances, %Appearance{})
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("remove-appearance", %{"index" => index}, socket) do
    changeset = remove_item(socket.assigns.changeset, :appearances, String.to_integer(index))
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("add-piece", _, socket) do
    changeset = add_item(socket.assigns.changeset, :pieces, %Piece{})
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("remove-piece", %{"index" => index}, socket) do
    changeset = remove_item(socket.assigns.changeset, :pieces, String.to_integer(index))
    {:noreply, assign(socket, changeset: changeset)}
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
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  # Private helpers

  defp add_item(changeset, field_name, item) do
    existing =
      changeset
      |> Changeset.get_field(field_name, [])
      |> exclude_obsolete()

    changeset |> Changeset.put_assoc(field_name, existing ++ [item])
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
