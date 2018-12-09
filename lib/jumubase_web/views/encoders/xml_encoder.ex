defmodule JumubaseWeb.XMLEncoder do
  @moduledoc """
  A tool to export data as XML for use in other Jumu software,
  most notably JMDaten.
  """

  alias Jumubase.Showtime.{Appearance, Instruments, Performance}

  @doc """
  Encodes the list of performances to XML.
  """
  def encode(performances) do
    {:jumu, nil, Enum.map(performances, &to_xml/1)} |> XmlBuilder.generate
  end

  # Private helpers

  defp to_xml(%Performance{contest_category: cc} = performance) do
    [a1 | rest] = performance.appearances
    {:teilnehmer, nil, [
      to_xml(a1),
      {:wertung, nil, [
        {:type, nil, map_type(cc.category.type)},
        {:instrument_stimmlage, nil, a1.instrument},
      ]},
      {:spielpartner, nil, Enum.map(rest, &{:partner, nil, to_xml(&1)})}
    ]}
  end
  defp to_xml(%Appearance{participant: p} = a) do
    [
      {:vorname, nil, p.given_name},
      {:nachname, nil, p.family_name},
      {:geburtstag, nil, p.birthdate},
      {:tel, nil, p.phone},
      {:email, nil, p.email},
      {:instrument, nil, Instruments.name(a.instrument)},
    ]
  end

  defp map_type("solo"), do: "solo"
  defp map_type("ensemble"), do: "gruppe"
end
