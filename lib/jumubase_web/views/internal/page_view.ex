defmodule JumubaseWeb.Internal.PageView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  import JumubaseWeb.PageView, only: [document_link: 2]
  alias JumubaseWeb.Endpoint
  alias JumubaseWeb.Internal.ContestLive

  def jury_material_link(title, file_name) do
    document_link(
      title,
      Routes.static_path(Endpoint, "/resources/jury_materials/#{file_name}")
    )
  end

  def meeting_minutes_link(city, year) do
    document_link(
      "LW #{year} #{city}",
      Routes.static_path(Endpoint, "/resources/meeting_minutes/LW-Protokoll #{year}.pdf")
    )
  end
end
