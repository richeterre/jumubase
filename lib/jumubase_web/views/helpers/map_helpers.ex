defmodule JumubaseWeb.MapHelpers do
  alias Jumubase.Foundation

  @doc """
  Returns an image url for a map showing all hosts.
  """
  def host_map_url do
    base_url = "https://maps.googleapis.com/maps/api/staticmap?scale=2&size=640x400"

    markers =
      Foundation.list_hosts()
      |> Enum.group_by(& &1.current_grouping, &{&1.latitude, &1.longitude})
      |> Enum.reduce("", fn {grouping, locations}, acc ->
        color = get_marker_color(grouping)
        acc <> get_markers(locations, color, grouping)
      end)

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

  defp get_marker_color(grouping) do
    case grouping do
      "1" -> "blue"
      "2" -> "green"
      "3" -> "yellow"
    end
  end

  defp get_markers(locations, color, label) do
    marker_locations =
      locations
      |> Enum.map(fn {lat, lon} -> "#{lat},#{lon}" end)
      |> Enum.join("|")

    "&markers=color:#{color}|label:#{label}|" <> marker_locations
  end

  def get_api_key do
    Application.get_env(:jumubase, __MODULE__)[:google_api_key]
  end
end
