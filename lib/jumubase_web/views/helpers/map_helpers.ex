defmodule JumubaseWeb.MapHelpers do
  alias Jumubase.Foundation

  @doc """
  Returns an image url for a map showing all hosts.
  """
  def host_map_url do
    base_url = "https://maps.googleapis.com/maps/api/staticmap?scale=2&size=640x400"

    markers = get_markers(Foundation.list_host_locations, "green")

    styles =
      "&style=element:labels|visibility:off" <>
      "&style=feature:administrative.neighborhood|visibility:off" <>
      "&style=feature:administrative|element:geometry|visibility:off" <>
      "&style=feature:poi|visibility:off" <>
      "&style=feature:road|visibility:off" <>
      "&style=feature:road|element:labels.icon|visibility:off" <>
      "&style=feature:transit|visibility:off"

    key = "&key=#{get_api_key()}"

    base_url <> markers <> styles <> key
  end

  # Private helpers

  defp get_markers(locations, color) do
    marker_locations =
      locations
      |> Enum.map(fn {lat, lon} -> "#{lat},#{lon}" end)
      |> Enum.join("|")

    "&markers=color:#{color}|" <> marker_locations
  end

  def get_api_key do
    Application.get_env(:jumubase, __MODULE__)[:google_api_key]
  end
end
