defmodule JumubaseWeb.PDFGenerator do
  alias JumubaseWeb.PDFGenerator.DefaultEngine

  # Private helpers

  defp get_engine do
    config = Application.get_env(:jumubase, __MODULE__, [])
    config[:engine] || DefaultEngine
  end
end
