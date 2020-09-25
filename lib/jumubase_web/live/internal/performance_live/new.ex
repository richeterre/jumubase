defmodule JumubaseWeb.Internal.PerformanceLive.New do
  use Phoenix.LiveView
  use JumubaseWeb.PerformanceLive, :new
  import Jumubase.Gettext
  import JumubaseWeb.PerformanceLive.Helpers
  alias Jumubase.Showtime
  alias JumubaseWeb.Router.Helpers, as: Routes

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
