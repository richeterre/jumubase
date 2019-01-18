defmodule JumubaseWeb.PDFGenerator.TestEngine do
  @moduledoc """
  Dummy PDF generator for test use. Always returns an empty binary.
  """

  @behaviour JumubaseWeb.PDFGenerator.Engine

  def jury_sheets(_performances, _round), do: <<>>
  def jury_table(_performances), do: <<>>
  def certificates(_performances, _contest), do: <<>>
end
