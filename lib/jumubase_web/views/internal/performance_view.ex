defmodule JumubaseWeb.Internal.PerformanceView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.AppearanceView, only: [
    acc: 1, age_group_badge: 1, badge: 1, instrument_name: 1, non_acc: 1
  ]
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  import JumubaseWeb.Internal.ParticipantView, only: [full_name: 1]
  import JumubaseWeb.Internal.PieceView, only: [
    composer_dates: 1, duration: 1, epoch_tag: 1, person_name: 1
  ]
  alias Jumubase.Showtime.Performance

  def category_name(%Performance{} = performance) do
    performance.contest_category.category.name
  end

  def category_info(%Performance{} = performance) do
    "#{category_name(performance)}, AG #{performance.age_group}"
  end

  @doc """
  Returns the performance's formatted duration.
  """
  def total_duration(%Performance{pieces: pieces}) do
    pieces
    |> calculate_total_duration
    |> Timex.Duration.to_time!
    |> Timex.Format.DateTime.Formatter.format!("%-M'%S", :strftime)
  end

  # Private helpers

  defp calculate_total_duration(pieces) do
    pieces
    |> Enum.reduce(Timex.Duration.zero, fn piece, total ->
      total
      |> Timex.Duration.add(Timex.Duration.from_minutes(piece.minutes))
      |> Timex.Duration.add(Timex.Duration.from_seconds(piece.seconds))
    end)
  end
end
