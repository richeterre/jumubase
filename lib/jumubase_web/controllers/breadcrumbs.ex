defmodule JumubaseWeb.Breadcrumbs do
  import Jumubase.Gettext
  import JumubaseWeb.Router.Helpers
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  alias Jumubase.Foundation.Contest

  @doc """
  Adds a breadcrumb to the navigation hierarchy.
  """
  def add_breadcrumb(conn, opts) do
    # We might need to assemble the path here, as generating it already
    # at the callsite does not always compile (e.g. in controller-level plugs)
    path = opts[:path] || opts[:path_fun].(JumubaseWeb.Endpoint, opts[:action])

    breadcrumb = [name: opts[:name], icon: opts[:icon], path: path]
    breadcrumbs = Map.get(conn.assigns, :breadcrumbs, []) ++ [breadcrumb]
    conn |> Plug.Conn.assign(:breadcrumbs, breadcrumbs)
  end

  @doc """
  Adds a breadcrumb for the internal home (root) path to the hierarchy.
  """
  def add_home_breadcrumb(conn, _opts) do
    add_breadcrumb(conn, name: nil, icon: "home", path: internal_page_path(conn, :home))
  end

  @doc """
  Adds a breadcrumb for the contest to the hierarchy.
  """
  def add_contest_breadcrumb(conn, %Contest{} = contest) do
    add_breadcrumb(conn, name: name_with_flag(contest),
      path: internal_contest_path(conn, :show, contest))
  end

  @doc """
  Adds a breadcrumb for the contest's performance list to the hierarchy.
  """
  def add_performances_breadcrumb(conn, %Contest{} = contest) do
    add_breadcrumb(conn, name: gettext("Performances"),
      path: internal_contest_performance_path(conn, :index, contest))
  end

  @doc """
  Adds a breadcrumb for the contest's category list to the hierarchy.
  """
  def add_contest_categories_breadcrumb(conn, %Contest{} = contest) do
    add_breadcrumb(conn, name: gettext("Categories"),
      path: internal_contest_contest_category_path(conn, :index, contest))
  end
end
