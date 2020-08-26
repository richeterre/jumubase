defmodule JumubaseWeb.PerformanceLive.Edit do
  use Phoenix.LiveView
  import Jumubase.Gettext
  import JumubaseWeb.PerformanceController, only: [normalize_params: 1]
  alias Ecto.Changeset
  alias Jumubase.Foundation
  alias Jumubase.Showtime
  alias Jumubase.Showtime.{Appearance, Performance}
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
    changeset = socket.assigns.changeset

    existing_appearances =
      case Map.get(changeset.changes, :appearances) do
        nil ->
          Map.get(changeset.data, :appearances, [])

        appearances ->
          appearances |> Enum.filter(&(&1.action != :replace))
      end

    items = existing_appearances ++ [%Appearance{}]
    {:noreply, assign(socket, changeset: Changeset.put_assoc(changeset, :appearances, items))}
  end

  def handle_event("remove-appearance", %{"index" => index}, socket) do
    changeset = socket.assigns.changeset
    index = String.to_integer(index)

    remaining_appearances =
      case Map.get(changeset.changes, :appearances) do
        nil ->
          Map.get(changeset.data, :appearances, []) |> List.delete_at(index)

        changesets ->
          changesets
          |> Enum.filter(&(&1.action != :replace))
          |> List.delete_at(index)
      end

    {:noreply,
     assign(socket, changeset: Changeset.put_assoc(changeset, :appearances, remaining_appearances))}
  end

  def handle_event("add-piece", _, socket) do
    {:noreply, socket}
  end

  def handle_event("remove-piece", %{"index" => _index}, socket) do
    {:noreply, socket}
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
end
