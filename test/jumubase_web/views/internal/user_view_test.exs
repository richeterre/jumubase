defmodule JumubaseWeb.Internal.UserViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias Jumubase.JumuParams
  alias Jumubase.Factory
  alias JumubaseWeb.Internal.UserView

  test "returns a user's full name" do
    user = Factory.build(:user, first_name: "First", last_name: "Last")
    assert UserView.full_name(user) == "First Last"
  end

  describe "role_tag/1" do
    test "returns nothing for RW Organizers" do
      user = Factory.build(:user, role: "rw-organizer")
      assert UserView.role_tag(user.role) == nil
    end

    test "returns a tag for all other roles" do
      for role <- JumuParams.roles() |> List.delete("rw-organizer") do
        user = Factory.build(:user, role: role)
        assert UserView.role_tag(user.role) != nil
      end
    end
  end
end
