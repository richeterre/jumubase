defmodule JumubaseWeb.LayoutView do
  use JumubaseWeb, :view
  import JumubaseWeb.BreadcrumbHelpers

  @doc """
  Tells whether the given breadcrumb is active.
  """
  def breadcrumb_active(conn, breadcrumb) do
    breadcrumb[:path] === conn.request_path
  end
end
