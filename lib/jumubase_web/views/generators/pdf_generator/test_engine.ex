defmodule JumubaseWeb.PDFGenerator.TestEngine do
  @moduledoc """
  Dummy PDF generator for test use. Always returns an empty binary.
  """

  @behaviour JumubaseWeb.PDFGenerator.Engine

  def jury_sheets(_performances, _round), do: <<>>
end
