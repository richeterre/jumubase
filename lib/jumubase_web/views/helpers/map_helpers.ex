defmodule JumubaseWeb.MapHelpers do
  def get_access_token do
    Application.get_env(:jumubase, __MODULE__)[:mapbox_access_token]
  end

  def get_mapbox_style_url do
    Application.get_env(:jumubase, __MODULE__)[:mapbox_style_url]
  end
end
