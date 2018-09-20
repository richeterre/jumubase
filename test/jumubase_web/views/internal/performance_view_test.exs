defmodule JumubaseWeb.PerformanceViewTest do
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
end
