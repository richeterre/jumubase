defmodule JumubaseWeb.Internal.ParticipantViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.Internal.ParticipantView

  test "full_name/1 returns a participant's full name" do
    participant = build(:participant, given_name: "A", family_name: "B")
    assert ParticipantView.full_name(participant) == "A B"
  end
end
