defmodule JumubaseWeb.LayoutView do
  use JumubaseWeb, :view
  import JumubaseWeb.BreadcrumbHelpers

  @doc """
  Returns the page title.
  """
  def title do
    release_level() |> title()
  end

  @doc """
  Returns an element to be shown in the navbar as the "brand" item.
  """
  def nav_brand_element do
    case release_level() do
      "production" -> img_tag("/images/jumuball.png", alt: gettext("Jumu logo"))
      release_level -> content_tag(:span, title(release_level))
    end
  end

  @doc """
  Tells whether the given breadcrumb is active.
  """
  def breadcrumb_active(conn, breadcrumb) do
    breadcrumb == List.last(conn.assigns.breadcrumbs)
  end

  # Private helpers

  defp title("production"), do: "Jumu weltweit"
  defp title("staging"), do: "Jumu STAGING"
  defp title(_), do: "Jumu DEV"

  defp release_level do
    Application.get_env(:jumubase, :release_level)
  end
end
