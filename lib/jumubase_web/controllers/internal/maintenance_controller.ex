defmodule JumubaseWeb.Internal.MaintenanceController do
  use JumubaseWeb, :controller
  alias Jumubase.Showtime

  plug :add_home_breadcrumb

  plug :add_breadcrumb,
    name: gettext("Data maintenance"),
    path_fun: &Routes.internal_maintenance_path/2,
    action: :index

  plug :admin_check

  def index(conn, _params) do
    orphaned_participants = Showtime.list_orphaned_participants()

    conn
    |> assign(:orphaned_participants, orphaned_participants)
    |> render("index.html")
  end

  def delete_orphaned_participants(conn, _params) do
    {count, nil} = Showtime.delete_orphaned_participants()

    conn
    |> put_flash(:success, delete_orphaned_success_text(count))
    |> redirect(to: Routes.internal_maintenance_path(conn, :index))
  end

  # Private helpers

  defp delete_orphaned_success_text(count) do
    ngettext(
      "DELETE_ORPHANED_PARTICIPANTS_SUCCESS_ONE",
      "DELETE_ORPHANED_PARTICIPANTS_SUCCESS_MANY(%{count})",
      count
    )
  end
end
