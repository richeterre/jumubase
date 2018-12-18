defmodule JumubaseWeb.Internal.PerformanceViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.Internal.PerformanceView

  describe "stage_info/1" do
    setup do
      p = build(:performance,
        stage: build(:stage, name: "Aula"), stage_time: ~N[2019-01-01T07:30:00]
      )
      [performance: p]
    end

    test "returns a performance's stage and stage time in full style", %{performance: p} do
      assert PerformanceView.stage_info(p, :full) == {"1 January 2019, 07:30", "Aula"}
    end

    test "returns a performance's stage and stage time in medium style", %{performance: p} do
      assert PerformanceView.stage_info(p, :medium) == {"1 January, 07:30", "Aula"}
    end

    test "returns nil if the performance doesn't contain any stage info" do
      p = build(:performance, stage: nil, stage_time: nil)
      assert PerformanceView.stage_info(p) == nil
    end
  end

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

  test "formatted_duration/1 returns the formatted duration of a performance" do
    p = build(:performance, pieces: [
      build(:piece, minutes: 1, seconds: 59),
      build(:piece, minutes: 2, seconds: 34)
    ])
    assert PerformanceView.formatted_duration(p) == "4'33"
  end
end
