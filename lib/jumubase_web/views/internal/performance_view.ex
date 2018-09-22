defmodule JumubaseWeb.Internal.PerformanceView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.AppearanceView, only: [acc: 1, instrument_name: 1, non_acc: 1]
  import JumubaseWeb.Internal.ParticipantView, only: [birthdate: 1, full_name: 1]
  alias Jumubase.Showtime.{Appearance, Performance}

  def category_name(%Performance{} = performance) do
    performance.contest_category.category.name
  end

  def category_info(%Performance{} = performance) do
    "#{category_name(performance)}, AG #{performance.age_group}"
  end
end
