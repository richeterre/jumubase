NimbleCSV.define(CSVParser, separator: "\t", escape: "\"")

defmodule JumubaseWeb.CSVEncoder do
  @moduledoc """
  A tool to export registration data as comma-separated values.
  """

  alias Jumubase.Showtime.Participant

  def encode(participants) do
    data = column_headers() ++ Enum.map(participants, &extract_data/1)
    CSVParser.dump_to_iodata(data)
  end

  # Private helpers

  defp column_headers do
    [~w(Vorname Nachname Geburtsdatum Telefon E-Mail)]
  end

  defp extract_data(%Participant{} = pt) do
    [
      pt.given_name,
      pt.family_name,
      Timex.format!(pt.birthdate, "{0D}.{0M}.{YYYY}"),
      pt.phone,
      pt.email
    ]
  end
end
