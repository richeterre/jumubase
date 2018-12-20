defmodule JumubaseWeb.Internal.ParticipantViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.Internal.ParticipantView

  test "full_name/1 returns a participant's full name" do
    participant = build(:participant, given_name: "Jane", family_name: "Doe")
    assert ParticipantView.full_name(participant) == "Jane Doe"
  end
end
