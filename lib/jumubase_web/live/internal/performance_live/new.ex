defmodule JumubaseWeb.Internal.PerformanceLive.New do
  use Phoenix.LiveView
  import Jumubase.Gettext
  import JumubaseWeb.PerformanceLive.Helpers

  import JumubaseWeb.PerformanceLive.New,
    only: [
      prepare: 2,
      change: 2,
      add_appearance: 1,
      remove_appearance: 2,
      add_piece: 1,
      remove_piece: 2
    ]

  alias Jumubase.Showtime
  alias JumubaseWeb.Router.Helpers, as: Routes

  def render(assigns) do
    JumubaseWeb.PerformanceView.render("live_form.html", assigns)
  end

  def mount(_params, assigns, socket) do
    {:ok, prepare(socket, assigns)}
  end

  def handle_event("change", %{"performance" => attrs}, socket) do
    {:noreply, change(socket, attrs)}
  end

  def handle_event("add-appearance", _, socket) do
    {:noreply, add_appearance(socket)}
  end

  def handle_event("remove-appearance", %{"index" => index}, socket) do
    {:noreply, remove_appearance(socket, parse_id(index))}
  end

  def handle_event("toggle-appearance-panel", %{"index" => index}, socket) do
    {:noreply, toggle_appearance_panel(socket, parse_id(index))}
  end

  def handle_event("add-piece", _, socket) do
    {:noreply, add_piece(socket)}
  end

  def handle_event("remove-piece", %{"index" => index}, socket) do
    {:noreply, remove_piece(socket, parse_id(index))}
  end

  def handle_event("toggle-piece-panel", %{"index" => index}, socket) do
    {:noreply, toggle_piece_panel(socket, parse_id(index))}
  end

  def handle_event("submit", %{"performance" => attrs}, socket) do
    contest = socket.assigns.contest

    case Showtime.create_performance(contest, attrs) do
      {:ok, performance} ->
        {:noreply,
         socket
         |> put_flash(:success, gettext("The performance was created."))
         |> redirect(
           to: Routes.internal_contest_performance_path(socket, :show, contest, performance)
         )}

      {:error, changeset} ->
        {:noreply, handle_failed_submit(socket, changeset)}
    end
  end
end
