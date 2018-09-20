defmodule JumubaseWeb.Internal.PerformanceController do
  use JumubaseWeb, :controller
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Contest
  alias Jumubase.Showtime

  plug :add_breadcrumb, icon: "home", path_fun: &internal_page_path/2, action: :home
  plug :add_breadcrumb, name: gettext("Contests"), path_fun: &internal_contest_path/2, action: :index

  plug :role_check, roles: ["admin"]

  def index(conn, %{"contest_id" => contest_id}) do
    contest =
      Foundation.get_contest!(contest_id)

    performances = Showtime.list_performances(contest)

    conn
    |> assign(:contest, contest)
    |> assign(:performances, performances)
    |> add_contest_breadcrumb(contest)
    |> add_performances_breadcrumb(contest)
    |> render("index.html")
  end
end
