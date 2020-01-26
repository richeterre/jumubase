NimbleCSV.define(CSVParser, separator: "\t", escape: "\"")

defmodule JumubaseWeb.CSVEncoder do
  @moduledoc """
  A tool to export registration data as comma-separated values.
  """

  import JumubaseWeb.Internal.PerformanceView, only: [category_name: 1]
  alias Jumubase.Showtime.{Participant, Performance}

  def encode(participants) do
    data = column_headers() ++ Enum.map(participants, &map_participant/1)
    CSVParser.dump_to_iodata(data)
  end

  # Private helpers

  defp column_headers do
    [~w(Nachname Vorname Geburtsdatum Telefon E-Mail Auftritte)]
  end

  defp map_participant(%Participant{} = pt) do
    [
      pt.family_name,
      pt.given_name,
      Timex.format!(pt.birthdate, "{0D}.{0M}.{YYYY}"),
      pt.phone,
      pt.email,
      Enum.map(pt.performances, &format_performance/1) |> Enum.join(", ")
    ]
  end

  defp format_performance(%Performance{} = p) do
    "#{category_name(p)} #{p.age_group}"
  end
end
