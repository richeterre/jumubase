defmodule JumubaseWeb.PerformanceLive.New do
  use Phoenix.LiveView
  use JumubaseWeb.PerformanceLive, :new
  import Jumubase.Gettext
  import JumubaseWeb.PerformanceLive.Helpers
  alias Jumubase.Mailer
  alias Jumubase.Showtime
  alias JumubaseWeb.Email
  alias JumubaseWeb.Router.Helpers, as: Routes

  def handle_event("submit", %{"performance" => attrs}, socket) do
    contest = socket.assigns.contest

    case Showtime.create_performance(contest, attrs) do
      {:ok, %{edit_code: edit_code} = performance} ->
        Email.registration_success(performance) |> Mailer.deliver_later()

        {:noreply,
         socket
         |> put_flash(:success, registration_success_message(edit_code))
         |> redirect(to: Routes.page_path(socket, :home))}

      {:error, changeset} ->
        {:noreply, handle_failed_submit(socket, changeset)}
    end
  end

  # Private helpers

  defp registration_success_message(edit_code) do
    success_msg = gettext("We received your registration!")

    edit_msg =
      gettext("You can still change it later using the edit code %{edit_code}.",
        edit_code: edit_code
      )

    "#{success_msg} #{edit_msg}"
  end
end
