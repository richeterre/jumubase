defmodule JumubaseWeb.XMLEncoder do
  @moduledoc """
  A tool to export data as XML for use in other Jumu software,
  most notably JMDaten.
  """

  alias Jumubase.Showtime
  alias Jumubase.Showtime.{Appearance, Instruments, Performance, Piece}

  @doc """
  Encodes the list of performances to XML.
  """
  def encode(performances) do
    performances = Showtime.load_pieces(performances)
    {:jumu, nil, Enum.map(performances, &to_xml/1)} |> XmlBuilder.generate()
  end

  # Private helpers

  defp to_xml(%Performance{appearances: appearances, contest_category: cc} = p) do
    for a <- appearances do
      other_appearances = appearances |> List.delete(a)

      {:teilnehmer, %{id: a.participant.id},
       [
         to_xml(a),
         {:wertung, %{id: p.id},
          [
            {:type, nil, map_role(a.role)},
            {:instrument_stimmlage, nil, Instruments.name(a.instrument)},
            {:kategorie, nil, map_category(cc.category)}
          ]},
         {:spielpartner, nil,
          Enum.map(other_appearances, &{:partner, %{id: &1.participant.id}, to_xml(&1)})},
         {:programme, nil, Enum.map(p.pieces, &to_xml/1)}
       ]}
    end
  end

  defp to_xml(%Appearance{participant: p} = a) do
    [
      {:vorname, nil, p.given_name},
      {:nachname, nil, p.family_name},
      {:geburtstag, nil, format_date(p.birthdate)},
      {:tel, nil, p.phone},
      {:email, nil, p.email},
      {:instrument, nil, Instruments.name(a.instrument)}
    ]
  end

  defp to_xml(%Piece{} = pc) do
    {:programm, %{id: pc.id},
     [
       map_person(pc),
       {:geburtsjahr, nil, pc.composer_born},
       {:sterbejahr, nil, pc.composer_died},
       {:epoche, nil, pc.epoch},
       {:titel_opus, nil, pc.title},
       {:spieldauer, nil, format_duration(pc)}
     ]}
  end

  defp map_role("soloist"), do: "solo"
  defp map_role("ensemblist"), do: "gruppe"
  defp map_role("accompanist"), do: "begleiter"

  defp map_category(%{type: "solo"}), do: "A21"
  defp map_category(%{type: "ensemble"}), do: "B85"

  defp map_person(%Piece{artist: nil, composer: composer}) do
    {first_names, [last_name]} = String.split(composer) |> Enum.split(-1)

    [
      {:komponist_nachname, nil, last_name},
      {:komponist_vorname1, nil, Enum.at(first_names, 0)},
      {:komponist_vorname2, nil, Enum.at(first_names, 1)},
      {:komponist_vorname3, nil, Enum.at(first_names, 2)}
    ]
  end

  defp map_person(%Piece{composer: nil, artist: artist}) do
    {:komponist_nachname, nil, artist}
  end

  defp format_date(date), do: Timex.format!(date, "{D}.{M}.{YYYY}")

  defp format_duration(%Piece{minutes: min, seconds: sec}) do
    "#{zero_pad(min)}:#{zero_pad(sec)}"
  end

  defp zero_pad(number) do
    number |> Integer.to_string() |> String.pad_leading(2, "0")
  end
end
