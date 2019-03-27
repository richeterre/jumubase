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
    performances =
      performances
      |> Showtime.load_pieces()
      |> Showtime.load_predecessor_contests()

    {:jumu, nil, Enum.map(performances, &to_xml/1)} |> XmlBuilder.generate()
  end

  # Private helpers

  defp to_xml(%Performance{contest_category: cc} = p) do
    appearances = Performance.result_groups(p) |> List.flatten()

    for a <- appearances do
      other_appearances = appearances |> List.delete(a)

      {:teilnehmer, %{id: a.participant.id},
       [
         to_xml(a),
         {:rwkurz, nil, p.predecessor_contest.host.name},
         {:wertung, %{id: p.id},
          [
            {:type, nil, map_role(a.role)},
            {:instrument_stimmlage, nil, Instruments.name(a.instrument)},
            {:kategorie, nil, cc.category.bw_code}
          ]},
         {:spielpartner, nil,
          Enum.map(other_appearances, &{:partner, %{id: &1.participant.id}, to_xml(&1)})},
         {:programme, nil, Enum.map(p.pieces, &to_xml/1)}
       ]}
    end
  end

  defp to_xml(%Appearance{participant: p} = a) do
    [
      {:nachname, nil, p.family_name},
      {:vorname, nil, p.given_name},
      {:geburtstag, nil, format_date(p.birthdate)},
      {:wohnbundesland, nil, "DSN"},
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
