defmodule JumubaseWeb.ErrorView do
  use JumubaseWeb, :view
  alias JumubaseWeb.LayoutView

  def render("404.html", assigns) do
    render_error_layout(
      assigns,
      dgettext("errors", "The page was not found."),
      dgettext("errors", "Maybe try one of the links above?")
    )
  end

  def render("500.html", assigns) do
    render_error_layout(
      assigns,
      dgettext("errors", "Oh no…"),
      dgettext("errors", "Something went wrong on the server. We’re on it!")
    )
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render("500.html", assigns)
  end

  # Private helpers

  defp render_error_layout(assigns, heading, message) do
    render(
      LayoutView,
      "error.html",
      assigns
      |> Map.put(:layout, {LayoutView, "root.html"})
      |> Map.put(:heading, heading)
      |> Map.put(:message, message)
    )
  end
end
