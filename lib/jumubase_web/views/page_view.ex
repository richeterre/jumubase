defmodule JumubaseWeb.PageView do
  use JumubaseWeb, :view

  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1, year: 1]

  alias Jumubase.Foundation
  alias Jumubase.Foundation.Host
  alias JumubaseWeb.Endpoint
  alias JumubaseWeb.MapHelpers

  def welcome_or_registration_phase_panel(conn) do
    case Foundation.get_latest_open_contest(1) do
      nil -> render("_welcome_phase_panel.html")
      c -> render("_registration_phase_panel.html", conn: conn, contest: c)
    end
  end

  def maybe_rw_phase_panel(conn) do
    if Foundation.has_ongoing_contests?(1) do
      render("_rw_phase_panel.html", conn: conn)
    end
  end

  def app_link(platform) do
    img_tag = img_tag(app_badge_path(platform), height: 40)
    link(img_tag, to: app_url(platform), class: "app-link")
  end

  def rule_booklet_link(title, year, opts \\ []) do
    document_link(
      title,
      Routes.static_path(Endpoint, "/resources/rule_booklets/Ausschreibung #{year}.pdf"),
      opts
    )
  end

  def document_link(title, path, opts \\ []) do
    icon_link("file", title, path, opts)
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

  def render("app_privacy.html", assigns) do
    render("app_privacy.#{get_locale()}.html", assigns)
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

  defp app_badge_path(:android), do: "/images/google-play-badge.png"
  defp app_badge_path(:ios), do: "/images/app-store-badge.svg"

  defp get_locale, do: Gettext.get_locale(Jumubase.Gettext)

  defp render_markdown(nil), do: nil

  defp render_markdown(markdown) do
    case Earmark.as_html(markdown, escape: false) do
      {:ok, result, _} -> raw(result)
      {:error, _, _} -> nil
    end
  end
end
