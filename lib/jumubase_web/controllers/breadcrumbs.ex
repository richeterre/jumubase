defmodule JumubaseWeb.Breadcrumbs do

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
end
