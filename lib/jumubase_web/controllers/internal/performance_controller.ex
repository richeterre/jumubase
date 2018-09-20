defmodule JumubaseWeb.Internal.PerformanceController do
  use JumubaseWeb, :controller
  import JumubaseWeb.Internal.PerformanceView, only: [category_name: 1]
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Contest
  alias Jumubase.Showtime
  alias Jumubase.Showtime.Performance

  plug :add_breadcrumb, icon: "home", path_fun: &internal_page_path/2, action: :home
  plug :add_breadcrumb, name: gettext("Contests"), path_fun: &internal_contest_path/2, action: :index

  plug :role_check, roles: ["admin"]

  # Pass contest from nested route to all actions
  def action(conn, _) do
    contest = Foundation.get_contest!(conn.params["contest_id"])
    args = [conn, conn.params, contest]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _params, contest) do
    performances = Showtime.list_performances(contest)

    conn
    |> assign(:contest, contest)
    |> assign(:performances, performances)
    |> add_contest_breadcrumb(contest)
    |> add_performances_breadcrumb(contest)
    |> render("index.html")
  end

  def show(conn, %{"id" => id}, contest) do
    performance = Showtime.get_performance!(contest, id)

    conn
    |> assign(:contest, contest)
    |> assign(:performance, performance)
    |> add_contest_breadcrumb(contest)
    |> add_performances_breadcrumb(contest)
    |> add_performance_breadcrumb(contest, performance)
    |> render("show.html")
  end

  # Private helpers

  def add_performance_breadcrumb(conn, %Contest{} = contest, %Performance{} = performance) do
    add_breadcrumb(conn, name: category_name(performance),
      path: internal_contest_performance_path(conn, :show, contest, performance))
  end
end