defmodule JumubaseWeb.Internal.ParticipantViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.Internal.ParticipantView

  describe "full_name/1" do
    test "returns a participant's full name" do
      participant = build(:participant, given_name: "Jane", family_name: "Doe")
      assert ParticipantView.full_name(participant) == "Jane Doe"
    end
  end

  describe "group_email_link" do
    test "returns a mailto link with unique participant emails in BCC" do
      pt1 = build(:participant, email: "a@example.org")
      pt2 = build(:participant, email: "b@example.org")
      pt3 = build(:participant, email: "b@example.org")
      pt4 = build(:participant, email: "c@example.org")
      assert ParticipantView.group_email_link([pt1, pt2, pt3, pt4])
        == "mailto:?bcc=a@example.org,b@example.org,c@example.org"
    end
  end
end
