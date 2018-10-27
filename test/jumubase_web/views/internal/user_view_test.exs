defmodule JumubaseWeb.Internal.UserViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.Internal.UserView

  test "returns a user's full name" do
    user = build(:user, given_name: "Given", family_name: "Family")
    assert UserView.full_name(user) == "Given Family"
  end

  test "returns the flags of a user's associated hosts" do
    h1 = build(:host, country_code: "FI")
    h2 = build(:host, country_code: "SE")
    user = build(:user, hosts: [h1, h2])
    assert UserView.host_flags(user) == ["🇫🇮", "🇸🇪"]
  end

  test "returns the names of a user's associated hosts" do
    h1 = build(:host, name: "DS Helsinki")
    h2 = build(:host, name: "DS Stockholm")
    user = build(:user, hosts: [h1, h2])
    assert UserView.host_names(user) == "DS Helsinki, DS Stockholm"
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
