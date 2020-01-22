defmodule JumubaseWeb.Internal.HostViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.Internal.HostView

  describe "flag/1" do
    test "returns a flag emoji for the host" do
      host = build(:host, country_code: "FI")
      assert HostView.flag(host) == "🇫🇮"
    end

    test "returns two flags for Israel/Palestine" do
      host = build(:host, country_code: "IL/PS", name: "Israel/Palästina")
      assert HostView.flag(host) == "🇮🇱🇵🇸"
    end
  end

  describe "name_with_flag/1" do
    test "returns a flag emoji and name for the host" do
      host = build(:host, country_code: "FI", name: "Helsinki")
      assert HostView.name_with_flag(host) == "🇫🇮 Helsinki"
    end
  end
end
