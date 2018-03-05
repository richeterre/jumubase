defmodule JumubaseWeb.IconHelpers do
  use Phoenix.HTML

  @doc """
  Generates a Glyphicon.
  """
  def icon_tag(icon) do
    content_tag(:span, nil, class: "glyphicon glyphicon-#{icon}")
  end

  @doc """
  Generates a link consisting only of an icon.
  """
  def icon_link(icon, path, opts \\ []) do
    link([to: path] ++ opts, do: icon_tag(icon))
  end

  @doc """
  Generates a textual link with a prepended icon.
  """
  def icon_text_link(icon, text, path, opts \\ []) do
    link([to: path] ++ opts, do: [icon_tag(icon), " ", text])
  end
end
