defmodule JumubaseWeb.Internal.StageViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.Internal.StageView

  describe "participant_names/1" do
    test "returns the full names of the performance's participants, separated by commas" do
      p = build(:performance, appearances: [
        build(:appearance, participant: build(:participant, given_name: "A", family_name: "B")),
        build(:appearance, participant: build(:participant, given_name: "C", family_name: "D")),
        build(:appearance, participant: build(:participant, given_name: "E", family_name: "F")),
      ])
      assert StageView.participant_names(p) == "A B, C D, E F"
    end
  end

  describe "scheduled_minutes/1" do
    test "rounds the performance's duration to the nearest 5-minute multiple" do
      p1 = build(:performance, pieces: [build(:piece, minutes: 10, seconds: 0)])
      p2 = build(:performance, pieces: [build(:piece, minutes: 10, seconds: 1)])
      assert StageView.scheduled_minutes(p1) == 10
      assert StageView.scheduled_minutes(p2) == 15
    end
  end

  describe "item_height/1" do
    test "converts a performance's duration to pixels" do
      p1 = build(:performance, pieces: [build(:piece, minutes: 10, seconds: 0)])
      p2 = build(:performance, pieces: [build(:piece, minutes: 10, seconds: 1)])
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
      [contest: insert(:contest), date: ~D[2019-01-01]]
    end

    test "returns a spacer minute map for a single-item performance list", %{contest: c, date: date} do
      stage_time = to_utc_datetime(date, ~T[09:30:00])
      p = insert_performance(c, stage_time: stage_time)
      assert StageView.spacer_map(date, [p]) == %{p.id => 30}
    end

    test "returns a spacer minute map for many performances", %{contest: c, date: date} do
      reference_time = to_utc_datetime(date, ~T[09:00:00])

      p1 = insert_performance(c,
        stage_time: Timex.shift(reference_time, minutes: 10),
        pieces: [build(:piece, minutes: 12, seconds: 0)] # taking up 15 minutes
      )
      p2 = insert_performance(c, stage_time: Timex.shift(reference_time, minutes: 30))

      assert StageView.spacer_map(date, [p1, p2]) == %{
        p1.id => 10,
        p2.id => 5
      }
    end

    test "returns an empty map for an empty performance list", %{date: date} do
      assert StageView.spacer_map(date, []) == %{}
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
