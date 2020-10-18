defmodule JumubaseWeb.PerformanceLive.HelpersTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.PerformanceLive.Helpers

  describe "predecessor_host_options/1" do
    test "returns formatted host options for a given LW contest, ordered by name" do
      # Matching hosts
      h1 = insert(:host, name: "B", current_grouping: "1")
      h2 = insert(:host, name: "A", current_grouping: "1")

      # Non-matching host
      insert(:host, current_grouping: "2")

      c = insert(:contest, host: h1, round: 2)
      assert Helpers.predecessor_host_options(c) == [{h2.name, h2.id}, {h1.name, h1.id}]
    end

    test "returns an empty list for a given RW contest" do
      c = insert(:contest, round: 1)
      assert Helpers.predecessor_host_options(c) == []
    end
  end

  describe "parse_id/1" do
    test "returns an integer for a valid string" do
      assert Helpers.parse_id("123") == 123
    end
  end
end
