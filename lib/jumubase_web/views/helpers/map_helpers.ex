defmodule JumubaseWeb.MapHelpers do

  @doc """
  Returns an image url for a map showing all hosts.
  """
  def host_map_url do
    base_url = "https://maps.googleapis.com/maps/api/staticmap?scale=2&size=640x400"

    markers =
      get_markers(green_host_coordinates(), "green") <>
      get_markers(yellow_host_coordinates(), "yellow") <>
      get_markers(blue_host_coordinates(), "blue")

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

  defp get_markers(coordinates, color) do
    coordinates
    |> Enum.reduce("", fn {lat, lon}, acc ->
      acc <> "&markers=color:#{color}%7C#{lat},#{lon}"
    end)
  end

  defp green_host_coordinates do
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

  defp blue_host_coordinates do
    [
      {41.3828055, 2.0888186}, # DS Barcelona
      {43.259737, -2.909638}, # DS Bilbao
      {28.0815404, -15.4696271}, # DS Gran Canaria
      {38.7589417, -9.1634023}, # DS Lissabon
      {40.5068422, -3.7054852}, # DS Madrid
      {36.5293663, -4.7536925}, # DS Marbella
      {41.1544284, -8.6375453}, # DS Porto
      {43.2982822, -1.9905614}, # DS San Sebastian
      {37.3864758, -5.9707329}, # DS Sevilla
      {28.40612, -16.55074}, # DS Teneriffa
      {39.482104, -0.363545}, # DS Valencia
    ]
  end

  defp yellow_host_coordinates do
    [
      {31.1920129, 29.897566}, # DS Alexandria
      {38.0367489, 23.7941474}, # DS Athen
      {31.7960191, 35.2307578}, # DS Jerusalem
      {41.0279912, 28.9757692}, # DS Istanbul
      {30.0323808, 31.2108091}, # DS Kairo-West
      {30.026485, 31.423194}, # DS Kairo-Ost
      {45.4761567, 9.1820931}, # DS Mailand
      {41.890161, 12.427013}, # DS Rom
      {40.5757672, 22.9863796}, # DS Thessaloniki
    ]
  end

  def get_api_key do
    Application.get_env(:jumubase, __MODULE__)[:google_api_key]
  end
end
