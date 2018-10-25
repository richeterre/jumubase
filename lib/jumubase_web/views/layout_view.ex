defmodule JumubaseWeb.LayoutView do
  use JumubaseWeb, :view
  import JumubaseWeb.BreadcrumbHelpers

  def title, do: "Jumu ♫ weltweit"

  @doc """
  Tells whether the given breadcrumb is active.
  """
  def breadcrumb_active(conn, breadcrumb) do
    breadcrumb == List.last(conn.assigns.breadcrumbs)
  end
end
