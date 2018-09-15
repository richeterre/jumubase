defmodule JumubaseWeb.IconHelpers do
  use Phoenix.HTML

  @doc """
  Generates a Glyphicon.
  """
  def icon_tag(icon) do
    content_tag(:span, nil, class: "glyphicon glyphicon-#{icon}")
  end

  @doc """
  Generates a link with an icon and optional text.
  """
  def icon_link(icon, text, path, opts \\ []) do
    link [to: path] ++ opts do
      if text, do: [icon_tag(icon), " ", text], else: icon_tag(icon)
    end
  end

  @doc """
  Returns an Emoji flag character for the given country code.
  """
  def emoji_flag(country_code) do
    country_code
    |> String.to_charlist
    |> Enum.map(&(127397 + &1))
    |> to_string
  end
end
