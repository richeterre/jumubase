defmodule JumubaseWeb.Internal.PageController do
  use JumubaseWeb, :controller
  import JumubaseWeb.Authorize
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Contest
  alias JumubaseWeb.Internal.Permit

  plug :add_home_breadcrumb

  plug :user_check

  def home(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) do
    contests =
      Contest
      |> Permit.scope_contests(user)
      |> Foundation.list_contests

    conn
    |> assign(:user, user)
    |> assign(:contests, contests)
    |> render("home.html")
  end
end
