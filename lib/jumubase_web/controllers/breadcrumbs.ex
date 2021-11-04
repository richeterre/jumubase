defmodule JumubaseWeb.Breadcrumbs do
  import Jumubase.Gettext
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  alias JumubaseWeb.Router.Helpers, as: Routes
  alias Jumubase.Foundation.Contest
  alias Plug.Conn
  alias Phoenix.LiveView

  @doc """
  Adds a breadcrumb to the navigation hierarchy.
  """
  def add_breadcrumb(%Conn{} = conn, opts) do
    breadcrumbs = Map.get(conn.assigns, :breadcrumbs, []) ++ [build_breadcrumb(opts)]
    conn |> Conn.assign(:breadcrumbs, breadcrumbs)
  end

  def add_breadcrumb(%LiveView.Socket{} = socket, opts) do
    breadcrumbs = Map.get(socket.assigns, :breadcrumbs, []) ++ [build_breadcrumb(opts)]
    socket |> LiveView.assign(:breadcrumbs, breadcrumbs)
  end

  @doc """
  Adds a breadcrumb for the internal home (root) path to the hierarchy.
  """
  def add_home_breadcrumb(conn, _opts) do
    add_breadcrumb(conn, name: nil, icon: "home", path: Routes.internal_page_path(conn, :home))
  end

  @doc """
  Adds a breadcrumb for the contest to the hierarchy.
  """
  def add_contest_breadcrumb(conn, %Contest{} = contest) do
    add_breadcrumb(conn,
      name: name_with_flag(contest),
      path: Routes.internal_contest_path(conn, :show, contest)
    )
  end

  @doc """
  Adds a breadcrumb for the contest's participant list to the hierarchy.
  """
  def add_participants_breadcrumb(conn, %Contest{} = contest) do
    add_breadcrumb(conn,
      name: gettext("Participants"),
      path: Routes.internal_contest_participant_path(conn, :index, contest)
    )
  end

  @doc """
  Adds a breadcrumb for the contest's performance list to the hierarchy.
  """
  def add_performances_breadcrumb(conn, %Contest{} = contest) do
    add_breadcrumb(conn,
      name: gettext("Performances"),
      path: Routes.internal_contest_performance_path(conn, :index, contest)
    )
  end

  @doc """
  Adds a breadcrumb for the contest's category list to the hierarchy.
  """
  def add_contest_categories_breadcrumb(conn, %Contest{} = contest) do
    add_breadcrumb(conn,
      name: gettext("Categories"),
      path: Routes.internal_contest_contest_category_path(conn, :index, contest)
    )
  end

  # Private helpers

  defp build_breadcrumb(opts) do
    # We sometimes to assemble the path here via a function, as generating it
    # at the callsite does not always compile (e.g. in controller-level plugs)
    path = opts[:path] || opts[:path_fun].(JumubaseWeb.Endpoint, opts[:action])
    [name: opts[:name], icon: opts[:icon], path: path]
  end
end
