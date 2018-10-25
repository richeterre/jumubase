defmodule JumubaseWeb.MapHelpers do

  @doc """
  Returns an image url for a map showing all hosts.
  """
  def host_map_url do
    base_url = "https://maps.googleapis.com/maps/api/staticmap?scale=2&size=640x400"

    markers =
      host_coordinates()
      |> Enum.reduce("", fn {lat, lon}, acc ->
        acc <> "&markers=color:green%7C#{lat},#{lon}"
      end)

    styles =
      "&style=element:labels%7Cvisibility:off" <>
      "&style=feature:administrative.neighborhood%7Cvisibility:off" <>
      "&style=feature:administrative%7Celement:geometry%7Cvisibility:off" <>
      "&style=feature:poi%7Cvisibility:off" <>
      "&style=feature:road%7Cvisibility:off" <>
      "&style=feature:road%7Celement:labels.icon%7Cvisibility:off" <>
      "&style=feature:transit%7Cvisibility:off"

    key = "&key=#{get_api_key()}"

    base_url <> markers <> styles <> key
  end

  # Private helpers

  defp host_coordinates do
    [
      {48.1491521,17.103554}, # DS Bratislava
      {50.8519895,4.4926787}, # DS Brüssel
      {47.51,18.983813}, # DS Budapest
      {25.2559086,51.501849}, # DS Doha
      {53.303453,-6.2293214}, # DS Dublin
      {46.2181677,6.0874632}, # DS Genf
      {60.167165,24.93205}, # DS Helsinki
      {55.6800835,12.5695033}, # DS Kopenhagen
      {51.4451339,-0.3050807}, # DS London
      {55.6643808,37.4953562}, # DS Moskau
      {59.9249933,10.7251024}, # DS Oslo
      {48.8423042,2.2035179}, # DS Paris
      {50.0556074,14.3541417}, # DS Prag
      {42.6691648,23.3492821}, # DS Sofia
      {59.3422421,18.0699085}, # DS Stockholm
      {52.1577924,21.0691116}, # DS Warschau
    ]
  end

  def get_api_key do
    Application.get_env(:jumubase, __MODULE__)[:google_api_key]
  end
end
