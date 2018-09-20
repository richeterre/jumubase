defmodule JumubaseWeb.JsonHelpers do
  import Phoenix.HTML, only: [raw: 1]

  @doc """
  Encodes a value as JSON and escapes it so that it can safely appear
  inline within a <script> tag.
  """
  def render_html_safe_json(value) do
    value
    |> Poison.encode!()
    |> String.replace("<", "\\u003c")
    |> String.replace(">", "\\u003e")
    |> raw()
  end
end
