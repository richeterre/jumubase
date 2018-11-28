defmodule JumubaseWeb.Internal.PerformanceController do
  use JumubaseWeb, :controller
  alias Jumubase.Foundation.Contest
  alias Jumubase.Showtime
  alias Jumubase.Showtime.Performance

  plug :add_home_breadcrumb
  plug :add_breadcrumb, name: gettext("Contests"), path_fun: &internal_contest_path/2, action: :index

  # Check nested contest permissions and pass to all actions
  def action(conn, _), do: contest_user_check_action(conn, __MODULE__)

  def index(conn, _params, contest) do
    performances = Showtime.list_performances(contest)

    conn
    |> assign(:contest, contest)
    |> assign(:performances, performances)
    |> add_breadcrumbs(contest)
    |> render("index.html")
  end

  def show(conn, %{"id" => id}, contest) do
    performance = Showtime.get_performance!(contest, id)

    conn
    |> assign(:contest, contest)
    |> assign(:performance, performance)
    |> add_breadcrumbs(contest, performance)
    |> render("show.html")
  end

  def delete(conn, %{"id" => id}, contest) do
    %{edit_code: ec} =
      Showtime.get_performance!(contest, id)
      |> Showtime.delete_performance!

    conn
    |> put_flash(:success,
      gettext("The performance with edit code %{edit_code} was deleted.", edit_code: ec)
    )
    |> redirect(to: internal_contest_performance_path(conn, :index, contest))
  end

  # Private helpers

  defp add_breadcrumbs(conn, %Contest{} = c) do
    conn
    |> add_contest_breadcrumb(c)
    |> add_performances_breadcrumb(c)
  end

  defp add_breadcrumbs(conn, %Contest{} = c, %Performance{} = p) do
    performance_path = internal_contest_performance_path(conn, :show, c, p)

    conn
    |> add_breadcrumbs(c)
    |> add_breadcrumb(name: p.edit_code, path: performance_path)
  end
end
