defmodule JumubaseWeb.EmailViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.EmailView

  describe "greeting/1" do
    test "returns a greeting for a single participant" do
      participant = build(:participant, given_name: "Anna")
      assert EmailView.greeting(participant) == "Hello Anna"
    end

    test "returns a greeting for two participants" do
      pts = [
        build(:participant, given_name: "Anna"),
        build(:participant, given_name: "Ben"),
      ]
      assert EmailView.greeting(pts) == "Hello Anna and Ben"
    end

    test "returns a greeting for more than two participants" do
      pts = [
        build(:participant, given_name: "Anna"),
        build(:participant, given_name: "Ben"),
        build(:participant, given_name: "Clara"),
      ]
      assert EmailView.greeting(pts) == "Hello Anna, Ben and Clara"
    end
  end
end
