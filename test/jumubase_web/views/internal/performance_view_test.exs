defmodule JumubaseWeb.Internal.PerformanceViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.Internal.PerformanceView

  describe "stage_time/1" do
    test "returns a performance's stage time in time-only style" do
      p = build(:performance, stage_time: ~N[2019-01-01T07:30:00])
      assert PerformanceView.stage_time(p) == "07:30"
    end
  end

  describe "stage_info/1" do
    setup do
      p =
        build(:performance,
          stage: build(:stage, name: "Aula"),
          stage_time: ~N[2019-01-01T07:30:00]
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
    p =
      build(:performance,
        contest_category:
          build(:contest_category,
            category: build(:category, name: "ABC")
          )
      )

    assert PerformanceView.category_name(p) == "ABC"
  end

  test "category_info/1 returns a performance's category name and age group" do
    p =
      build(:performance,
        contest_category:
          build(:contest_category,
            category: build(:category, name: "ABC")
          ),
        age_group: "IV"
      )

    assert PerformanceView.category_info(p) == "ABC, AG IV"
  end

  describe "predecessor_info/1" do
    test "returns the predecessor contest's host flag" do
      p =
        build(:performance,
          predecessor_contest: build(:contest, host: build(:host, country_code: "FI"))
        )

      assert PerformanceView.predecessor_info(p) == "🇫🇮"
    end

    test "returns nil if the performance has no predecessor contest" do
      p = build(:performance, predecessor_contest: nil)
      assert PerformanceView.predecessor_info(p) == nil
    end
  end

  test "formatted_duration/1 returns the formatted duration of a performance" do
    p =
      build(:performance,
        pieces: [
          build(:piece, minutes: 1, seconds: 59),
          build(:piece, minutes: 2, seconds: 34)
        ]
      )

    assert PerformanceView.formatted_duration(p) == "4'33"
  end

  describe "sorted_appearances/1" do
    test "returns a solo performance's appearances in display order" do
      sol = build(:appearance, role: "soloist")
      [acc1, acc2] = build_list(2, :appearance, role: "accompanist")
      p = build(:performance, appearances: [acc2, sol, acc1])
      assert PerformanceView.sorted_appearances(p) == [sol, acc2, acc1]
    end

    test "returns an ensemble performance's appearances in display order" do
      [ens1, ens2] = build_list(2, :appearance, role: "ensemblist")
      [acc1, acc2] = build_list(2, :appearance, role: "accompanist")
      p = build(:performance, appearances: [acc2, ens2, acc1, ens1])
      assert PerformanceView.sorted_appearances(p) == [ens2, ens1, acc2, acc1]
    end
  end

  test "appearance_ids/1 returns the appearances' ids as a comma-separated string" do
    a1 = build(:appearance, id: 1)
    a2 = build(:appearance, id: 2)
    a3 = build(:appearance, id: 3)
    assert PerformanceView.appearance_ids([a1, a2, a3]) == "1,2,3"
  end
end
