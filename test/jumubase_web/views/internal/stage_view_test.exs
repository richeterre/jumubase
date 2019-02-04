defmodule JumubaseWeb.Internal.StageViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.Internal.StageView

  describe "short_category_info/1" do
    test "returns the category and age group in a short style" do
      p =
        build(:performance,
          contest_category:
            build(:contest_category,
              category: build(:category, name: "Gesang (Pop) solo", short_name: "PopGesang")
            ),
          age_group: "III"
        )

      assert StageView.short_category_info(p) == "PopGesang III"
    end
  end

  describe "appearances_info/1" do
    test "returns participant names and instruments of the performance's appearances" do
      p =
        build(:performance,
          appearances: [
            build(:appearance,
              instrument: "violin",
              participant: build(:participant, given_name: "A", family_name: "B")
            ),
            build(:appearance,
              instrument: "violoncello",
              participant: build(:participant, given_name: "C", family_name: "D")
            ),
            build(:appearance,
              instrument: "piano",
              participant: build(:participant, given_name: "E", family_name: "F")
            )
          ]
        )

      assert StageView.appearances_info(p) == "A B, Violin\nC D, Violoncello\nE F, Piano"
    end
  end

  describe "scheduled_minutes/1" do
    test "rounds up a performance's duration to the nearest 5-minute grid step" do
      p1 = build(:performance, pieces: [build(:piece, minutes: 10, seconds: 0)])
      p2 = build(:performance, pieces: [build(:piece, minutes: 11, seconds: 0)])
      assert StageView.scheduled_minutes(p1) == 10
      assert StageView.scheduled_minutes(p2) == 15
    end

    test "rounds down a performance's duration if it's very close to the next-lowest grid step" do
      p1 = build(:performance, pieces: [build(:piece, minutes: 10, seconds: 30)])
      p2 = build(:performance, pieces: [build(:piece, minutes: 10, seconds: 31)])
      assert StageView.scheduled_minutes(p1) == 10
      assert StageView.scheduled_minutes(p2) == 15
    end
  end

  describe "item_height/1" do
    test "converts a performance's duration to pixels" do
      p1 = build(:performance, pieces: [build(:piece, minutes: 10, seconds: 0)])
      p2 = build(:performance, pieces: [build(:piece, minutes: 10, seconds: 31)])
      assert StageView.item_height(p1) == "40px"
      assert StageView.item_height(p2) == "60px"
    end

    test "converts minutes to pixels" do
      assert StageView.item_height(10) == "40px"
      assert StageView.item_height(15) == "60px"
    end
  end

  describe "spacer_map/1" do
    setup do
      [contest: insert(:contest), start: ~N[2019-01-01T09:30:00]]
    end

    test "returns a spacer minute map for a single-item performance list", %{
      contest: c,
      start: start
    } do
      p = insert_performance(c, stage_time: start)
      assert StageView.spacer_map([p]) == %{p.id => 0}
    end

    test "returns a spacer minute map for many performances", %{contest: c, start: start} do
      p1 =
        insert_performance(c,
          stage_time: start,
          # taking up 15 minutes
          pieces: [build(:piece, minutes: 12, seconds: 0)]
        )

      p2 = insert_performance(c, stage_time: Timex.shift(start, minutes: 30))

      assert StageView.spacer_map([p1, p2]) == %{
               p1.id => 15,
               p2.id => 0
             }
    end

    test "returns an empty map for an empty performance list" do
      assert StageView.spacer_map([]) == %{}
    end
  end

  describe "playtime_percentage/1" do
    test "returns what percentage of the performance's schedule minutes is taken up by playtime" do
      p1 = build(:performance, pieces: [build(:piece, minutes: 12, seconds: 0)])
      p2 = build(:performance, pieces: [build(:piece, minutes: 15, seconds: 0)])
      assert StageView.playtime_percentage(p1) == "80.0%"
      assert StageView.playtime_percentage(p2) == "100.0%"
    end
  end
end
