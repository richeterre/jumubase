defmodule JumubaseWeb.Internal.ContestLive.OpenRegistration do
  use Phoenix.LiveView
  import Jumubase.Gettext
  alias Jumubase.Accounts
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Contest
  alias JumubaseWeb.Router.Helpers, as: Routes

  def render(assigns) do
    JumubaseWeb.Internal.ContestView.render("open_registration_live.html", assigns)
  end

  def mount(_params, assigns, socket) do
    {:ok, prepare(socket, assigns)}
  end

  def handle_event("change", %{"contest" => params}, socket) do
    changeset =
      Contest.dates_changeset(socket.assigns.contest, params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("submit", %{"contest" => params}, socket) do
    contest = socket.assigns.contest

    case Foundation.verify_dates_and_open_contest(contest, params) do
      {:ok, contest} ->
        success_msg =
          gettext(
            "Registration for your contest is now open. You can find the form on the registration page."
          )

        {:noreply,
         socket
         |> put_flash(:success, success_msg)
         |> redirect(to: Routes.internal_contest_path(socket, :show, contest))}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  # Private helpers

  defp prepare(socket, %{"contest_id" => c_id, "user_token" => token}) do
    user = Accounts.get_user_by_session_token(token)
    contest = Foundation.get_contest!(c_id)

    socket
    |> assign(current_user: user)
    |> assign(contest: contest)
    |> assign(changeset: Contest.dates_changeset(contest, %{}))
  end
end
