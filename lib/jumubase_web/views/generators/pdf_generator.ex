defmodule JumubaseWeb.PDFGenerator do
  alias JumubaseWeb.PDFGenerator.DefaultEngine

  def jury_sheets(performances, round) do
    get_engine().jury_sheets(performances, round)
  end

  def jury_table(performances) do
    get_engine().jury_table(performances)
  end

  # Private helpers

  defp get_engine do
    config = Application.get_env(:jumubase, __MODULE__, [])
    config[:engine] || DefaultEngine
  end
end
