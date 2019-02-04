defmodule JumubaseWeb.Internal.AppearanceViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.Internal.AppearanceView

  test "appearance_info/1 returns the participant's full name and instrument name" do
    a =
      build(:appearance,
        participant: build(:participant, given_name: "A", family_name: "B"),
        instrument: "piano"
      )

    assert AppearanceView.appearance_info(a) == "A B, Piano"
  end

  test "instrument_name/1 returns an instrument's display name" do
    assert AppearanceView.instrument_name("piano") == "Piano"
  end

  test "participant_names/1 returns the participant's names from a list of appearances" do
    a1 = build(:appearance, participant: build(:participant, given_name: "A", family_name: "B"))
    a2 = build(:appearance, participant: build(:participant, given_name: "C", family_name: "D"))
    assert AppearanceView.participant_names([a2, a1]) == "C D, A B"
  end
end
