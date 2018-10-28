defmodule JumubaseWeb.PageView do
  use JumubaseWeb, :view
  import JumubaseWeb.LayoutView, only: [title: 0]
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  alias JumubaseWeb.MapHelpers

  def host_map_image do
    img_tag MapHelpers.host_map_url, class: "img-responsive map-image"
  end

  def render("rules.html", assigns) do
    locale = Gettext.get_locale(Jumubase.Gettext)
    render("rules.#{locale}.html", assigns)
  end

  def render_markdown(nil), do: nil
  def render_markdown(markdown) do
    case Earmark.as_html(markdown) do
      {:ok, result, _} -> raw(result)
      {:error, _, _} -> nil
    end
  end
end
