defmodule JumubaseWeb.Breadcrumbs do

  @doc """
  Adds a breadcrumb to the navigation hierarchy.
  """
  def add_breadcrumb(conn, opts) do
    breadcrumb = [name: opts[:name], icon: opts[:icon], path: opts[:path]]
    breadcrumbs = Map.get(conn.assigns, :breadcrumbs, []) ++ [breadcrumb]
    conn |> Plug.Conn.assign(:breadcrumbs, breadcrumbs)
  end
end
