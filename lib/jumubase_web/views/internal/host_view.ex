defmodule JumubaseWeb.Internal.HostView do
  use JumubaseWeb, :view
  alias Jumubase.JumuParams
  alias Jumubase.Foundation.Host

  @doc """
  Returns the flag associated with the host.
  """
  def flag(%Host{country_code: country_code}) do
    emoji_flag(country_code)
  end

  @doc """
  Returns the host's name and associated flag.
  """
  def name_with_flag(%Host{} = h) do
    "#{flag(h)} #{h.name}"
  end

  @doc """
  Returns a list of possible `grouping` values suitable for forms.
  """
  def grouping_options do
    JumuParams.groupings()
  end
end
