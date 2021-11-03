defmodule JumubaseWeb.Internal.PageController do
  use JumubaseWeb, :controller
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Contest
  alias JumubaseWeb.Internal.Permit

  plug :add_home_breadcrumb

  def home(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) do
    permitted = Permit.scope_contests(Contest, user)
    contests = Foundation.list_latest_relevant_contests(permitted, user)
    count = Foundation.count_contests(permitted)

    conn
    |> assign(:user, user)
    |> assign(:contests, contests)
    |> assign(:has_more, length(contests) < count)
    |> render("home.html")
  end

  def jury_work(conn, _params) do
    conn
    |> add_breadcrumb(
      name: gettext("Jury work"),
      path: Routes.internal_page_path(conn, :jury_work)
    )
    |> render("jury_work.html")
  end

  def literature_guidance(conn, _params) do
    conn
    |> add_breadcrumb(
      name: gettext("Literature guidance"),
      path: Routes.internal_page_path(conn, :literature_guidance)
    )
    |> render("literature_guidance.html")
  end

  def meeting_minutes(conn, _params) do
    conn
    |> add_breadcrumb(
      name: gettext("Meeting minutes"),
      path: Routes.internal_page_path(conn, :meeting_minutes)
    )
    |> render("meeting_minutes.html")
  end
end
