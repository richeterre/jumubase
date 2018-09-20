defmodule JumubaseWeb.Internal.PerformanceView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.AppearanceView, only: [instrument_name: 1]
  import JumubaseWeb.Internal.ParticipantView, only: [birthdate: 1, full_name: 1]
  alias Jumubase.Showtime.Performance

  def category_name(%Performance{} = performance) do
    performance.contest_category.category.name
  end
end
