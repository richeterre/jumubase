defmodule JumubaseWeb.Internal.PageController do
  use JumubaseWeb, :controller
  import JumubaseWeb.Authorize
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Contest
  alias JumubaseWeb.Internal.Permit

  plug :add_home_breadcrumb

  plug :user_check

  def home(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) do
    permitted = Permit.scope_contests(Contest, user)
    contests = Foundation.list_relevant_contests(permitted, user)
    count = Foundation.count_contests(permitted)

    conn
    |> assign(:user, user)
    |> assign(:contests, contests)
    |> assign(:has_more, length(contests) < count)
    |> render("home.html")
  end
end
