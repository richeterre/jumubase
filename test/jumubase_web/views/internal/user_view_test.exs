defmodule JumubaseWeb.Internal.UserViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.Internal.UserView

  test "returns a user's full name" do
    user = build(:user, given_name: "Given", family_name: "Family")
    assert UserView.full_name(user) == "Given Family"
  end

  test "returns the names and flags of a user's associated hosts" do
    h1 = build(:host, name: "Helsinki", country_code: "FI")
    h2 = build(:host, name: "Stockholm", country_code: "SE")
    user = build(:user, hosts: [h1, h2])
    assert UserView.host_flags(user) == ["🇫🇮 Helsinki", "🇸🇪 Stockholm"]
  end

  test "returns the names of a user's associated hosts" do
    h1 = build(:host, name: "Helsinki")
    h2 = build(:host, name: "Stockholm")
    user = build(:user, hosts: [h1, h2])
    assert UserView.host_names(user) == "Helsinki, Stockholm"
  end

  describe "role_tag/1" do
    test "returns nothing for RW Organizers" do
      user = build(:user, role: "local-organizer")
      assert UserView.role_tag(user.role) == nil
    end

    test "returns a tag for all other roles" do
      for role <- List.delete(all_roles(), "local-organizer") do
        user = build(:user, role: role)
        assert UserView.role_tag(user.role) != nil
      end
    end
  end
end
