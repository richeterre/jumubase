defmodule JumubaseWeb.Api.PerformanceView do
  import JumubaseWeb.Internal.AppearanceView, only: [instrument_name: 1]
  import JumubaseWeb.Internal.ParticipantView, only: [full_name: 1]

  import JumubaseWeb.Internal.PerformanceView,
    only: [
      category_name: 1,
      predecessor_host_country: 1,
      predecessor_host_name: 1,
      sorted_appearances: 1
    ]

  alias Jumubase.Foundation.Contest
  alias Jumubase.Showtime.Results
  alias Jumubase.Showtime.{Appearance, Performance, Piece}

  def render("index.json", %{performances: performances, contest: c}) do
    performances |> Enum.map(&render_performance(&1, c))
  end

  # Private helpers

  defp render_performance(%Performance{} = p, %Contest{} = c) do
    %{time_zone: tz} = c.host

    %{
      id: to_string(p.id),
      category_name: category_name(p),
      predecessor_host_name: predecessor_host_name(p),
      predecessor_host_country: predecessor_host_country(p),
      age_group: p.age_group,
      stage_time: p.stage_time |> to_local_datetime(tz),
      appearances: sorted_appearances(p) |> Enum.map(&render_appearance(&1, p, c.round)),
      pieces: p.pieces |> Enum.map(&render_piece/1)
    }
  end

  defp render_appearance(%Appearance{participant: pt} = a, %Performance{} = p, round) do
    appearance = %{
      participant_name: full_name(pt),
      participant_role: a.role,
      instrument_name: instrument_name(a.instrument),
      age_group: a.age_group
    }

    if p.results_public do
      appearance |> Map.put(:result, render_result(a, p, round))
    else
      appearance
    end
  end

  defp render_piece(%Piece{} = pc) do
    %{
      title: pc.title,
      composer_name: pc.composer || pc.artist,
      composer_born: pc.composer_born || "",
      composer_died: pc.composer_died || "",
      duration: duration_in_seconds(pc),
      epoch: pc.epoch
    }
  end

  defp render_result(%Appearance{} = a, %Performance{} = p, round) do
    %{
      points: a.points,
      prize: Results.get_prize(a.points, round),
      rating: Results.get_rating(a.points, round),
      advances_to_next_round: Results.advances?(a, p)
    }
  end

  defp to_local_datetime(nil, _time_zone), do: nil

  defp to_local_datetime(datetime, time_zone) do
    datetime
    |> NaiveDateTime.to_erl()
    |> Timex.to_datetime(time_zone)
  end

  defp duration_in_seconds(%Piece{minutes: min, seconds: sec}) do
    min * 60 + sec
  end
end
