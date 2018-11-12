defmodule JumubaseWeb.DateHelpers do
  @doc """
  Formats the given date for display.
  """
  def format_date(date, style \\ :full)
  def format_date(%Date{} = date, style) do
    locale = Timex.Translator.current_locale
    Timex.lformat!(date, date_format(locale, style), locale)
  end
  def format_date(nil, _style), do: nil

  # Private helpers

  # Returns a date format for the locale.
  defp date_format("de", :full), do: "{D}. {Mfull} {YYYY}"
  defp date_format("de", :medium), do: "{D}. {Mfull}"
  defp date_format("en", :full), do: "{D} {Mfull} {YYYY}"
  defp date_format("en", :medium), do: "{D} {Mfull}"
end
