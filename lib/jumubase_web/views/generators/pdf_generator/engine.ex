defmodule JumubaseWeb.PDFGenerator.Engine do
  @type performance :: Jumubase.Showtime.Performance.t()
  @type contest :: Jumubase.Foundation.Contest.t()

  @callback jury_sheets([performance], integer) :: binary
end
