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

  def format_datetime(%DateTime{} = datetime, style \\ :full) do
    locale = Timex.Translator.current_locale
    Timex.lformat!(datetime, datetime_format(locale, style), locale)
  end

  # Private helpers

  # Returns a date format for the locale.
  defp date_format("de", :full), do: "{D}. {Mfull} {YYYY}"
  defp date_format("de", :medium), do: "{D}. {Mfull}"
  defp date_format("en", :full), do: "{D} {Mfull} {YYYY}"
  defp date_format("en", :medium), do: "{D} {Mfull}"

  defp datetime_format(locale, style) do
    date_format(locale, style) <> ", {h24}:{m}"
  end
end
