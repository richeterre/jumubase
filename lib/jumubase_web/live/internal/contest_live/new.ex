defmodule JumubaseWeb.Internal.ContestLive.New do
  use Phoenix.LiveView
  import Jumubase.Gettext
  import JumubaseWeb.Internal.ContestView, only: [name: 1, round_options: 0]
  import JumubaseWeb.Internal.HostView, only: [grouping_options: 0]
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Contest
  alias JumubaseWeb.Router.Helpers, as: Routes

  def render(assigns) do
    JumubaseWeb.Internal.ContestView.render("live_form.html", assigns)
  end

  def mount(_params, _assigns, socket) do
    {:ok, prepare(socket)}
  end

  def handle_event("change", %{"contest" => attrs}, socket) do
    {:noreply, change(socket, attrs)}
  end

  def handle_event("submit", %{"contest" => attrs}, socket) do
    case Foundation.create_contest(attrs) do
      {:ok, %Contest{id: id}} ->
        contest = Foundation.get_contest!(id)
        message = gettext("The contest %{name} was created.", name: name(contest))

        {:noreply,
         socket
         |> put_flash(:success, message)
         |> redirect(to: Routes.internal_contest_path(socket, :index))}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  # Private helpers

  defp prepare(socket) do
    assign(socket,
      changeset: Foundation.change_contest(%Contest{}),
      round_options: round_options(),
      host_options: [],
      grouping_options: grouping_options()
    )
  end

  defp change(socket, attrs) do
    changeset =
      Contest.changeset(%Contest{}, attrs)
      |> Map.put(:action, :insert)

    host_options = host_options(attrs["grouping"])

    assign(socket, changeset: changeset, host_options: host_options)
  end

  defp host_options(nil), do: []

  defp host_options(grouping) do
    Foundation.list_hosts_by_grouping(grouping) |> Enum.map(&{&1.name, &1.id})
  end
end
