defmodule JumubaseWeb.Internal.PerformanceViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.Internal.PerformanceView

  test "category_name/1 returns a performance's category name" do
    p = build(:performance,
      contest_category: build(:contest_category,
        category: build(:category, name: "ABC")
      )
    )
    assert PerformanceView.category_name(p) == "ABC"
  end

  test "category_info/1 returns a performance's category name and age group" do
    p = build(:performance,
      contest_category: build(:contest_category,
        category: build(:category, name: "ABC")
      ),
      age_group: "IV"
    )
    assert PerformanceView.category_info(p) == "ABC, AG IV"
  end

  test "total_duration/1 returns the total duration of a performance" do
    p = build(:performance, pieces: [
      build(:piece, minutes: 1, seconds: 59),
      build(:piece, minutes: 2, seconds: 34)
    ])
    assert PerformanceView.total_duration(p) == "4'33"
  end
end
