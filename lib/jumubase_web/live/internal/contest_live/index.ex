defmodule JumubaseWeb.Internal.ContestLive.Index do
  use JumubaseWeb, :live_view
  import JumubaseWeb.Internal.ContestView, only: [round_options: 0]
  alias Jumubase.JumuParams
  alias Jumubase.Accounts
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Contest
  alias Jumubase.Foundation.ContestFilter
  alias JumubaseWeb.Internal.Permit
  alias JumubaseWeb.Internal.ContestLive

  def render(assigns) do
    JumubaseWeb.Internal.ContestView.render("index.html", assigns)
  end

  def mount(_params, assigns, socket) do
    {:ok, prepare(socket, assigns)}
  end

  def handle_params(%{"filter" => filter_params}, _url, socket) do
    filter = ContestFilter.from_params(filter_params)
    filter_cs = ContestFilter.changeset(filter_params)

    contests =
      Contest
      |> Permit.scope_contests(socket.assigns.current_user)
      |> Foundation.list_contests(filter)

    {:noreply, assign(socket, contests: contests, filter_changeset: filter_cs)}
  end

  def handle_params(_params, _url, socket) do
    # Since no filter was passed, we apply the default filter
    # (if possible) and update the URL accordingly using `push_patch`

    case Foundation.list_seasons() |> List.first() do
      nil ->
        {:noreply, socket}

      latest_season ->
        filter_map = %ContestFilter{season: latest_season} |> ContestFilter.to_filter_map()

        {:noreply,
         push_patch(socket,
           to: Routes.internal_live_path(socket, ContestLive.Index, filter: filter_map)
         )}
    end
  end

  def handle_event("filter", %{"contest_filter" => filter_params}, socket) do
    {:noreply,
     push_patch(socket,
       to: Routes.internal_live_path(socket, ContestLive.Index, filter: filter_params)
     )}
  end

  # Private helpers

  defp prepare(socket, %{"user_token" => token}) do
    user = Accounts.get_user_by_session_token(token)

    socket
    |> add_breadcrumb(icon: "home", path: Routes.internal_page_path(socket, :home))
    |> add_breadcrumb(
      name: gettext("Contests"),
      path: Routes.internal_live_path(socket, ContestLive.Index)
    )
    |> assign(
      current_user: user,
      contests: [],
      filter_changeset: ContestFilter.changeset(%{}),
      season_options: season_options(),
      round_options: round_options(),
      grouping_options: grouping_options()
    )
  end

  defp season_options do
    Enum.map(Foundation.list_seasons(), &{JumuParams.year(&1), &1})
  end

  defp grouping_options do
    Enum.map(JumuParams.groupings(), &{gettext("Grouping %{name}", name: &1), &1})
  end
end
