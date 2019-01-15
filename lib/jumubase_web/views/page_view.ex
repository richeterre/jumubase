defmodule JumubaseWeb.PageView do
  use JumubaseWeb, :view
  import JumubaseWeb.LayoutView, only: [title: 0]
  import JumubaseWeb.Internal.ContestView, only: [deadline_info: 2, name_with_flag: 1]
  alias Jumubase.JumuParams
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Host
  alias JumubaseWeb.Endpoint
  alias JumubaseWeb.MapHelpers

  def host_map_image do
    img_tag MapHelpers.host_map_url, class: "img-responsive map-image"
  end

  def render_phase_panels(conn) do
    today = Timex.today
    c = Foundation.get_latest_official_contest

    cond do
      Timex.after?(today, c.deadline) ->
        render "_rw_phase_panels.html", conn: conn
      true ->
        jumu_year = JumuParams.year(c.season)
        render "_pre_rw_phase_panels.html", conn: conn, year: jumu_year
    end
  end

  def app_link(title, platform, opts) when platform in [:android, :ios] do
    opts = opts |> Keyword.put(:to, app_url(platform))
    link title, opts
  end

  def rule_booklet_link(title, year, opts \\ []) do
    icon_link "file", title,
      Routes.static_path(Endpoint, "/resources/Ausschreibung_#{year}.pdf"),
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

  defp app_url(:android) do
    "https://play.google.com/store/apps/details?id=#{app_id(:android)}&hl=de"
  end
  defp app_url(:ios) do
    "https://itunes.apple.com/de/app/id#{app_id(:ios)}?mt=8"
  end

  defp app_id(platform) do
    Application.get_env(:jumubase, :app_ids)[platform]
  end

  defp get_locale, do: Gettext.get_locale(Jumubase.Gettext)

  defp render_markdown(nil), do: nil
  defp render_markdown(markdown) do
    case Earmark.as_html(markdown) do
      {:ok, result, _} -> raw(result)
      {:error, _, _} -> nil
    end
  end
end
