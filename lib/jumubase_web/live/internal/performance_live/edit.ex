defmodule JumubaseWeb.Internal.PerformanceLive.Edit do
  use Phoenix.LiveView
  use JumubaseWeb.PerformanceLive, :edit
  import Jumubase.Gettext
  import JumubaseWeb.PerformanceController, only: [normalize_params: 1]
  import JumubaseWeb.PerformanceLive.Helpers
  alias Ecto.Changeset
  alias Jumubase.Showtime
  alias JumubaseWeb.Router.Helpers, as: Routes

  def handle_event("submit", %{"performance" => params}, socket) do
    contest = socket.assigns.contest
    performance = socket.assigns.performance

    params = normalize_params(params)

    case Showtime.update_performance(contest, performance, params) do
      {:ok, performance} ->
        {:noreply,
         socket
         |> put_flash(:success, gettext("The performance was updated."))
         |> redirect(
           to: Routes.internal_contest_performance_path(socket, :show, contest, performance)
         )}

      {:error, %Changeset{} = changeset} ->
        {:noreply, handle_failed_submit(socket, changeset)}

      {:error, :has_results} ->
        {:noreply, handle_has_results_error(socket, contest)}
    end
  end

  defp handle_has_results_error(socket, contest) do
    error_msg =
      gettext("This performance already has results. To edit it, please clear them first.")

    socket
    |> put_flash(:error, error_msg)
    |> redirect(to: Routes.internal_contest_performance_path(socket, :index, contest))
  end
end
