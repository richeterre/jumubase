defmodule JumubaseWeb.BreadcrumbHelpers do
  use Phoenix.HTML
  import JumubaseWeb.IconHelpers

  @doc """
  Renders a single breadcrumb based on the available params.
  """
  def render_breadcrumb(path, icon, name) do
    case {path, icon, name} do
      {nil, icon, nil} -> icon_tag(icon)
      {nil, nil, name} -> name
      {path, icon, nil} -> icon_link(icon, nil, path)
      {path, nil, name} -> link(name, to: path)
    end
  end
end
