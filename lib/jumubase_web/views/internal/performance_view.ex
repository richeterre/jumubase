defmodule JumubaseWeb.Internal.PerformanceView do
  use JumubaseWeb, :view
  alias Jumubase.Showtime.Performance

  def category_name(%Performance{} = performance) do
    performance.contest_category.category.name
  end
end
