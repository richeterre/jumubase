defmodule JumubaseWeb.PerformanceLive.Edit do
  use Phoenix.LiveView
  use JumubaseWeb.PerformanceLive, :edit
  import Jumubase.Gettext
  import JumubaseWeb.PerformanceController, only: [normalize_params: 1]
  import JumubaseWeb.PerformanceLive.Helpers
  alias Jumubase.Showtime
  alias Jumubase.Showtime.Performance
  alias JumubaseWeb.Router.Helpers, as: Routes

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
end
