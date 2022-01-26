defmodule JumubaseWeb.Internal.PerformanceLive.Advancing do
  use Phoenix.LiveView
  import Jumubase.Gettext
  import Jumubase.Utils, only: [get_ids: 1]
  import JumubaseWeb.Internal.ContestView, only: [name: 1]
  alias Jumubase.Accounts
  alias Jumubase.Foundation
  alias Jumubase.Showtime
  alias JumubaseWeb.Internal.Permit
  alias JumubaseWeb.Router.Helpers, as: Routes

  def render(assigns) do
    JumubaseWeb.Internal.PerformanceView.render("advancing_live.html", assigns)
  end

  def mount(_params, session, socket) do
    {:ok, prepare(socket, session)}
  end

  defp prepare(socket, %{"user_token" => token, "contest_id" => c_id}) do
    user = Accounts.get_user_by_session_token(token)
    contest = Foundation.get_contest!(c_id)
    performances = contest |> Showtime.advancing_performances() |> Showtime.load_successors()

    target_contest_options = target_contest_options(contest)

    assign(socket,
      current_user: user,
      contest: contest,
      performances: performances,
      target_contest_options: target_contest_options,
      target_contest: nil,
      can_migrate?: Permit.authorized?(user, :migrate_advancing) and target_contest_options != [],
      can_submit?: false,
      can_export?: Permit.authorized?(user, :export_advancing) and contest.round == 2
    )
  end

  def handle_event("change", %{"migration" => migration}, socket) do
    contest = socket.assigns.contest
    target_contest = get_target_contest(migration)
    performances = contest |> Showtime.advancing_performances() |> Showtime.load_successors()

    if target_contest do
      target_category_ids =
        target_contest.contest_categories
        |> Enum.map(& &1.category_id)

      eligible_performances =
        performances
        |> Enum.filter(&(&1.contest_category.category_id in target_category_ids))

      {:noreply,
       assign(socket,
         performances: eligible_performances,
         target_contest: target_contest,
         can_submit?: !Enum.empty?(performances)
       )}
    else
      {:noreply,
       assign(socket, performances: performances, target_contest: nil, can_submit?: false)}
    end
  end

  def handle_event("submit", _params, socket) do
    current_user = socket.assigns.current_user
    contest = socket.assigns.contest
    performance_ids = get_ids(socket.assigns.performances)
    target_contest = socket.assigns.target_contest

    socket =
      with true <- Permit.authorized?(current_user, :migrate_advancing),
           {:ok, count} <- Showtime.migrate_performances(contest, performance_ids, target_contest) do
        put_success_message(socket, count)
      else
        _ -> put_error_message(socket)
      end

    redirect_path = Routes.internal_contest_performances_path(socket, :advancing, contest)
    {:noreply, redirect(socket, to: redirect_path)}
  end

  # Private helpers

  defp target_contest_options(contest) do
    Foundation.get_successors(contest) |> Enum.map(&{name(&1), &1.id})
  end

  defp get_target_contest(migration) do
    case Map.get(migration, "target_contest_id", "") do
      "" -> nil
      id -> Foundation.get_contest!(id) |> Foundation.load_contest_categories()
    end
  end

  defp put_success_message(socket, count) do
    put_flash(
      socket,
      :success,
      ngettext(
        "MIGRATE_PERFORMANCES_SUCCESS_ONE",
        "MIGRATE_PERFORMANCES_SUCCESS_MANY(%{count})",
        count
      )
    )
  end

  defp put_error_message(socket) do
    put_flash(socket, :error, gettext("The performances could not be migrated."))
  end
end
