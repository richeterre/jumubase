defmodule JumubaseWeb.Api.PerformanceView do
  import JumubaseWeb.Internal.AppearanceView, only: [instrument_name: 1]
  import JumubaseWeb.Internal.ParticipantView, only: [full_name: 1]
  import JumubaseWeb.Internal.PerformanceView, only: [category_name: 1]
  alias Jumubase.Showtime.{Appearance, Performance, Piece}

  def render("index.json", %{performances: performances}) do
    performances |> Enum.map(&render_performance/1)
  end

  # Private helpers

  defp render_performance(%Performance{} = p) do
    %{
      id: to_string(p.id),
      category_name: category_name(p),
      age_group: p.age_group,
      stage_time: to_utc_datetime(p.stage_time),
      appearances: p.appearances |> Enum.map(&render_appearance/1),
      pieces: p.pieces |> Enum.map(&render_piece/1),
    }
  end

  defp render_appearance(%Appearance{participant: pt} = a) do
    %{
      participant_name: full_name(pt),
      participant_role: a.role,
      instrument_name: instrument_name(a.instrument),
      age_group: a.age_group,
    }
  end

  defp render_piece(%Piece{} = pc) do
    %{
      title: pc.title,
      composer_name: pc.composer || pc.artist,
      composer_born: pc.composer_born,
      composer_died: pc.composer_died,
      duration: duration_in_seconds(pc),
      epoch: pc.epoch,
    }
  end

  defp to_utc_datetime(datetime) do
    datetime |> DateTime.from_naive!("Etc/UTC")
  end

  defp duration_in_seconds(%Piece{minutes: min, seconds: sec}) do
    min * 60 + sec
  end
end
