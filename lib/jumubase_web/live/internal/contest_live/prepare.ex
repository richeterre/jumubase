defmodule JumubaseWeb.Internal.ContestLive.Prepare do
  use JumubaseWeb, :live_view
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  alias Jumubase.Accounts
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Contest
  alias JumubaseWeb.Internal.ContestLive

  def render(assigns) do
    JumubaseWeb.Internal.ContestView.render("prepare.html", assigns)
  end

  def mount(params, assigns, socket) do
    {:ok, prepare(socket, params, assigns)}
  end

  def handle_event("change", %{"contest" => params}, socket) do
    changeset =
      Contest.preparation_changeset(socket.assigns.contest, params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("submit", %{"contest" => params}, socket) do
    contest = socket.assigns.contest

    case Foundation.prepare_contest_for_registration(contest, params) do
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

  defp prepare(socket, %{"contest_id" => c_id}, %{"user_token" => token}) do
    user = Accounts.get_user_by_session_token(token)
    contest = Foundation.get_contest!(c_id)

    socket
    |> add_breadcrumbs(contest)
    |> assign(current_user: user)
    |> assign(contest: contest)
    |> assign(changeset: Contest.preparation_changeset(contest, %{}))
  end

  defp add_breadcrumbs(socket, contest) do
    socket
    |> add_breadcrumb(icon: "home", path: Routes.internal_page_path(socket, :home))
    |> add_breadcrumb(
      name: gettext("Contests"),
      path: Routes.internal_live_path(socket, ContestLive.Index)
    )
    |> add_breadcrumb(
      name: name_with_flag(contest),
      path: Routes.internal_contest_path(socket, :show, contest)
    )
    |> add_breadcrumb(
      name: gettext("Open Registration"),
      path: Routes.internal_contest_live_path(socket, ContestLive.Prepare, contest)
    )
  end
end
