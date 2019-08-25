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

  def countly_app_key do
    Application.get_env(:jumubase, :analytics)[:countly_app_key]
  end

  def countly_server_url do
    Application.get_env(:jumubase, :analytics)[:countly_server_url]
  end

  def countly_sdk_url, do: "#{countly_server_url()}/sdk/web/countly.min.js"
end
