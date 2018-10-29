defmodule JumubaseWeb.PageView do
  use JumubaseWeb, :view
  import JumubaseWeb.LayoutView, only: [title: 0]
  import JumubaseWeb.Internal.ContestView,
    only: [name_with_flag: 1, deadline_info: 2]
  alias Jumubase.Foundation.Host
  alias JumubaseWeb.MapHelpers

  def host_map_image do
    img_tag MapHelpers.host_map_url, class: "img-responsive map-image"
  end

  def render("rules.html", assigns) do
    locale = Gettext.get_locale(Jumubase.Gettext)
    render("rules.#{locale}.html", assigns)
  end

  def to_accordion_item(%Host{} = host) do
    %{id: host.id, title: host.name, body: render_markdown(host.address)}
  end

  # Private helpers

  defp render_markdown(nil), do: nil
  defp render_markdown(markdown) do
    case Earmark.as_html(markdown) do
      {:ok, result, _} -> raw(result)
      {:error, _, _} -> nil
    end
  end
end
