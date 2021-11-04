defmodule JumubaseWeb.Internal.PageView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  import JumubaseWeb.PageView, only: [document_link: 2]
  alias JumubaseWeb.Endpoint
  alias JumubaseWeb.Email
  alias JumubaseWeb.Internal.ContestLive

  def admin_email do
    config = Application.get_env(:jumubase, Email)
    config[:admin_email]
  end

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
