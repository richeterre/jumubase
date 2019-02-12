defmodule JumubaseWeb.Internal.MaintenanceController do
  use JumubaseWeb, :controller
  alias Jumubase.Utils
  alias Jumubase.Showtime

  plug :add_home_breadcrumb

  plug :add_breadcrumb,
    name: gettext("Data maintenance"),
    path_fun: &Routes.internal_maintenance_path/2,
    action: :index

  plug :admin_check

  def index(conn, _params) do
    duplicate_pairs = Showtime.list_duplicate_participants()
    orphaned_participants = Showtime.list_orphaned_participants()

    conn
    |> assign(:duplicate_pairs, duplicate_pairs)
    |> assign(:orphaned_participants, orphaned_participants)
    |> render("index.html")
  end

  def delete_orphaned_participants(conn, _params) do
    {count, nil} = Showtime.delete_orphaned_participants()

    conn
    |> put_flash(:success, delete_orphaned_success_text(count))
    |> redirect(to: Routes.internal_maintenance_path(conn, :index))
  end

  def compare_participants(conn, %{"base_id" => base_id, "other_id" => other_id}) do
    base_pt = Showtime.get_participant!(base_id)
    other_pt = Showtime.get_participant!(other_id)

    conn
    |> assign(:base, base_pt)
    |> assign(:other, other_pt)
    |> add_breadcrumb(name: gettext("Compare participants"), path: current_path(conn))
    |> render("compare_participants.html")
  end

  def merge_participants(conn, %{
        "base_id" => base_id,
        "other_id" => other_id,
        "merge_fields" => merge_fields
      }) do
    fields_to_merge = extract_merge_field_atoms(merge_fields)

    conn =
      case Showtime.merge_participants(base_id, other_id, fields_to_merge) do
        :ok ->
          put_flash(conn, :success, gettext("The participants were merged."))

        :error ->
          put_flash(conn, :error, gettext("The participants could not be merged."))
      end

    redirect(conn, to: Routes.internal_maintenance_path(conn, :index))
  end

  # Private helpers

  defp delete_orphaned_success_text(count) do
    ngettext(
      "DELETE_ORPHANED_PARTICIPANTS_SUCCESS_ONE",
      "DELETE_ORPHANED_PARTICIPANTS_SUCCESS_MANY(%{count})",
      count
    )
  end

  defp extract_merge_field_atoms(field_map) do
    field_map
    |> Enum.filter(fn {_, value} -> Utils.parse_bool(value) end)
    |> Enum.map(fn {key, _} -> String.to_existing_atom(key) end)
  end
end
