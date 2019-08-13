defmodule JumubaseWeb.PageView do
  use JumubaseWeb, :view
  import JumubaseWeb.LayoutView, only: [title: 0]

  import JumubaseWeb.Internal.ContestView,
    only: [deadline: 1, deadline_info: 2, name_with_flag: 1, year: 1]

  alias Jumubase.JumuParams
  alias Jumubase.Foundation
  alias Jumubase.Foundation.{Contest, Host}
  alias JumubaseWeb.PageView
  alias JumubaseWeb.Endpoint
  alias JumubaseWeb.MapHelpers

  def host_map_image do
    img_tag(MapHelpers.host_map_url(), class: "img-responsive map-image")
  end

  def render_phase_panels(conn) do
    c = Foundation.get_latest_official_contest()
    do_render_phase_panels(conn, c)
  end

  def app_link(platform) do
    img_tag = img_tag(app_badge_path(platform), height: 40)
    link(img_tag, to: app_url(platform), class: "app-link")
  end

  def grouping_options do
    JumuParams.groupings() |> Enum.map(&{grouping_name(&1), &1})
  end

  def rules_fragment(grouping) do
    "_grouping_#{grouping}_rules.html"
  end

  def rule_booklet_link(title, year, opts \\ []) do
    icon_link(
      "file",
      title,
      Routes.static_path(Endpoint, "/resources/Ausschreibung_#{year}.pdf"),
      opts
    )
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

  def render("scripts.rules.html", _assigns) do
    ~E{<script src="/js/groupingPicker.js"></script>}
  end

  def render("scripts.privacy.html", _assigns) do
    ~E{<script src="/js/privacy.js"></script>}
  end

  def to_accordion_item(%Host{} = host) do
    %{id: host.id, title: host.name, body: render_markdown(host.address)}
  end

  # Private helpers

  defp do_render_phase_panels(_conn, nil), do: nil

  defp do_render_phase_panels(conn, %Contest{round: 1} = c) do
    if Timex.after?(Timex.today(), c.deadline) do
      render("_rw_phase_panels.html", conn: conn)
    else
      render("_pre_rw_phase_panels.html", conn: conn, year: year(c))
    end
  end

  defp do_render_phase_panels(conn, %Contest{round: 2} = c) do
    if Timex.after?(Timex.today(), c.deadline) do
      render("_lw_phase_panels.html", conn: conn, contest: c)
    else
      render("_pre_lw_phase_panels.html", conn: conn, contest: c)
    end
  end

  defp app_url(:android) do
    "https://play.google.com/store/apps/details?id=#{app_id(:android)}&hl=de"
  end

  defp app_url(:ios) do
    "https://itunes.apple.com/de/app/id#{app_id(:ios)}?mt=8"
  end

  defp app_id(platform) do
    Application.get_env(:jumubase, :app_ids)[platform]
  end

  defp app_badge_path(:android), do: "/images/google-play-badge.png"
  defp app_badge_path(:ios), do: "/images/app-store-badge.svg"

  defp get_locale, do: Gettext.get_locale(Jumubase.Gettext)

  defp grouping_name(grouping) do
    case grouping do
      "1" -> "#{gettext("Grouping")} 1 — #{gettext("blue")}"
      "2" -> "#{gettext("Grouping")} 2 — #{gettext("green")}"
      "3" -> "#{gettext("Grouping")} 3 — #{gettext("yellow")}"
    end
  end

  defp render_markdown(nil), do: nil

  defp render_markdown(markdown) do
    case Earmark.as_html(markdown) do
      {:ok, result, _} -> raw(result)
      {:error, _, _} -> nil
    end
  end
end
