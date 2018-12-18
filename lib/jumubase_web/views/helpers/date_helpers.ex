defmodule JumubaseWeb.DateHelpers do
  @doc """
  Constructs a UTC datetime using the given date and time.
  """
  def to_naive_datetime(%Date{} = date, %Time{} = time) do
    NaiveDateTime.new(date, time) |> elem(1)
  end

  @doc """
  Formats the given date for display.
  """
  def format_date(date, style \\ :full)
  def format_date(%Date{} = date, style) do
    locale = Timex.Translator.current_locale
    Timex.lformat!(date, date_format(locale, style), locale)
  end
  def format_date(nil, _style), do: nil

  def format_datetime(datetime, style \\ :full)
  def format_datetime(%NaiveDateTime{} = datetime, style) do
    locale = Timex.Translator.current_locale
    Timex.lformat!(datetime, datetime_format(locale, style), locale)
  end
  def format_datetime(nil, _style), do: nil

  # Private helpers

  # Returns a date format for the locale.
  defp date_format("de", :full), do: "{D}. {Mfull} {YYYY}"
  defp date_format("de", :medium), do: "{D}. {Mfull}"
  defp date_format("en", :full), do: "{D} {Mfull} {YYYY}"
  defp date_format("en", :medium), do: "{D} {Mfull}"

  defp datetime_format(_locale, :time), do: "{h24}:{m}"
  defp datetime_format(locale, style) do
    date_format(locale, style) <> ", {h24}:{m}"
  end
end
