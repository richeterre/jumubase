defmodule JumubaseWeb.PageController do
  use JumubaseWeb, :controller
  import Jumubase.Gettext
  alias Jumubase.Foundation
  alias Jumubase.Showtime

  def home(conn, _params) do
    render(conn, "home.html")
  end

  def registration(conn, _params) do
    rw_contests = Foundation.list_open_contests(1)
    kimu_contests = Foundation.list_open_contests(0)
    general_deadline = Foundation.general_deadline(rw_contests ++ kimu_contests)

    conn
    |> assign(:rw_contests, rw_contests)
    |> assign(:kimu_contests, kimu_contests)
    |> assign(:general_deadline, general_deadline)
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
    conn
    |> assign(:hosts, Foundation.list_hosts)
    |> render("contact.html")
  end

  def privacy(conn, _params) do
    conn
    |> render("privacy.html")
  end

  # Private helpers

  defp show_error(conn, message) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: page_path(conn, :edit_registration))
  end

  defp perform_lookup(conn, edit_code) do
    case Showtime.lookup_performance(edit_code) do
      {:ok, %{contest_category: %{contest: c}} = performance} ->
        conn
        |> redirect(to: performance_path(conn, :edit, c, performance, edit_code: edit_code))
      {:error, _} ->
        show_error(conn, gettext("We could not find a registration for this edit code."))
    end
  end
end
