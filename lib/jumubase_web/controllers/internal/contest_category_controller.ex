defmodule JumubaseWeb.Internal.ContestCategoryController do
  use JumubaseWeb, :controller
  alias Jumubase.Foundation

  plug :add_home_breadcrumb
  plug :add_breadcrumb, name: gettext("Contests"), path_fun: &Routes.internal_contest_path/2, action: :index

  # Check nested contest permissions and pass to all actions
  def action(conn, _), do: contest_user_check_action(conn, __MODULE__)

  def index(conn, _params, contest) do
    contest_categories = Foundation.list_contest_categories(contest)

    conn
    |> assign(:contest, contest)
    |> assign(:contest_categories, contest_categories)
    |> add_contest_breadcrumb(contest)
    |> add_contest_categories_breadcrumb(contest)
    |> render("index.html")
  end
end
