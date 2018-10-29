defmodule JumubaseWeb.Internal.ContestController do
  use JumubaseWeb, :controller
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Contest
  alias JumubaseWeb.Internal.Permit

  plug :add_home_breadcrumb
  plug :add_breadcrumb, name: gettext("Contests"), path_fun: &internal_contest_path/2, action: :index

  plug :user_check when action in [:index]
  plug :contest_check when action in [:show]

  def index(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) do
    contests =
      Contest
      |> Permit.scope_contests(user)
      |> Foundation.list_contests

    conn
    |> assign(:contests, contests)
    |> render("index.html")
  end

  def show(conn, %{"id" => id}) do
    contest =
      Foundation.get_contest!(id)
      |> Foundation.load_contest_categories

    conn
    |> assign(:contest, contest)
    |> add_contest_breadcrumb(contest)
    |> render("show.html")
  end
end
