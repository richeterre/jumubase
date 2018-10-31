defmodule JumubaseWeb.PageView do
  use JumubaseWeb, :view
  import JumubaseWeb.LayoutView, only: [title: 0]
  import JumubaseWeb.Internal.ContestView,
    only: [deadline_info: 2, format_date: 1, name_with_flag: 1]
  alias Jumubase.Foundation.Host
  alias JumubaseWeb.Endpoint
  alias JumubaseWeb.MapHelpers

  def host_map_image do
    img_tag MapHelpers.host_map_url, class: "img-responsive map-image"
  end

  def rule_booklet_link(title, year, opts \\ []) do
    icon_link "file", title,
      static_path(Endpoint, "/resources/Ausschreibung_#{year}.pdf"),
      opts
  end

  def render("rules.html", assigns) do
    render("rules.#{get_locale()}.html", assigns)
  end

  def render("faq.html", assigns) do
    render("faq.#{get_locale()}.html", assigns)
  end

  def render("privacy.html", assigns) do
    render("privacy.#{get_locale()}.html", assigns)
  end

  def to_accordion_item(%Host{} = host) do
    %{id: host.id, title: host.name, body: render_markdown(host.address)}
  end

  # Private helpers

  defp get_locale, do: Gettext.get_locale(Jumubase.Gettext)

  defp render_markdown(nil), do: nil
  defp render_markdown(markdown) do
    case Earmark.as_html(markdown) do
      {:ok, result, _} -> raw(result)
      {:error, _, _} -> nil
    end
  end
end
