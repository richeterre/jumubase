defmodule JumubaseWeb.Internal.HostView do
  use JumubaseWeb, :view
  alias Jumubase.JumuParams

  @doc """
  Returns a list of possible `grouping` values suitable for forms.
  """
  def grouping_options do
    JumuParams.groupings()
  end
end
