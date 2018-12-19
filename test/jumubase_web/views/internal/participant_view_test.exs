defmodule JumubaseWeb.Internal.ParticipantViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.Internal.ParticipantView

  test "full_name/1 returns a participant's full name" do
    participant = build(:participant, given_name: "Jane", family_name: "Doe")
    assert ParticipantView.full_name(participant) == "Jane Doe"
  end

  test "short_name/1 returns a participant's given name and abbreviated family name" do
    participant = build(:participant, given_name: "Jane", family_name: "Doe")
    assert ParticipantView.short_name(participant) == "Jane D"
  end
end
