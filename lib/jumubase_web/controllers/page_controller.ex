defmodule JumubaseWeb.PageController do
  use JumubaseWeb, :controller
  import Jumubase.Gettext
  import Jumubase.Foundation.Contest, only: [deadline_passed?: 2]
  alias Jumubase.Foundation
  alias Jumubase.Showtime

  def home(conn, _params) do
    host_map_data =
      Foundation.list_hosts()
      |> Foundation.remove_archived_hosts()
      |> Enum.group_by(
        & &1.current_grouping,
        &%{"name" => &1.name, "latitude" => &1.latitude, "longitude" => &1.longitude}
      )
      |> Enum.reduce([], fn {grouping, hosts}, acc ->
        acc ++ [%{"grouping" => grouping, "hosts" => hosts}]
      end)

    conn
    |> assign(:host_map_data, host_map_data)
    |> render("home.html")
  end

  def registration(conn, _params) do
    rw_contests = Foundation.list_open_contests(1)
    lw_contests = Foundation.list_open_contests(2)
    kimu_contests = Foundation.list_open_contests(0)

    conn
    |> assign(:jumu_contests, rw_contests ++ lw_contests)
    |> assign(:kimu_contests, kimu_contests)
    |> render("registration.html")
  end

  def edit_registration(conn, _params) do
    conn
    |> render("edit_registration.html")
  end

  def lookup_registration(conn, %{"search" => %{"edit_code" => edit_code}}) do
    case String.trim(edit_code) do
      "" ->
        show_error(conn, gettext("Please enter an edit code."))

      edit_code ->
        perform_lookup(conn, edit_code)
    end
  end

  def rules(conn, _params) do
    render(conn, "rules.html")
  end

  def faq(conn, _params) do
    render(conn, "faq.html")
  end

  def contact(conn, _params) do
    hosts =
      Foundation.list_hosts_by_grouping("2")
      |> Foundation.remove_archived_hosts()

    conn
    |> assign(:hosts, hosts)
    |> render("contact.html")
  end

  def privacy(conn, _params) do
    conn
    |> render("privacy.html")
  end

  def app_privacy(conn, _params) do
    conn
    |> render("app_privacy.html")
  end

  # Private helpers

  defp show_error(conn, message) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: Routes.page_path(conn, :edit_registration))
  end

  defp perform_lookup(conn, edit_code) do
    with {:ok, %{contest_category: %{contest: c}} = p} <- Showtime.lookup_performance(edit_code),
         false <- deadline_passed?(c, Timex.today()) do
      redirect(conn, to: Routes.performance_path(conn, :edit, c, p, edit_code: edit_code))
    else
      {:error, _} ->
        show_error(conn, gettext("We could not find a registration for this edit code."))

      true ->
        show_error(
          conn,
          gettext(
            "The edit deadline for this contest has passed. Please contact us if you need assistance."
          )
        )
    end
  end
end
