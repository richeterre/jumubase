defmodule JumubaseWeb.PDFGenerator.Engine do
  @type performance :: Jumubase.Showtime.Performance.t()
  @type contest :: Jumubase.Foundation.Contest.t()

  @callback jury_sheets([performance], integer) :: binary
  @callback jury_table([performance]) :: binary
  @callback certificates([performance], contest) :: binary
end
