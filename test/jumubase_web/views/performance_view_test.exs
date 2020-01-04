defmodule JumubaseWeb.PerformanceViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.PerformanceView

  describe "predecessor_host_options/1" do
    test "returns formatted host options for a given LW contest, ordered by name" do
      # Matching hosts
      h1 = insert(:host, name: "B", current_grouping: "1")
      h2 = insert(:host, name: "A", current_grouping: "1")

      # Non-matching host
      insert(:host, current_grouping: "2")

      c = insert(:contest, host: h1, round: 2)
      assert PerformanceView.predecessor_host_options(c) == [{h2.name, h2.id}, {h1.name, h1.id}]
    end

    test "returns an empty list for a given RW contest" do
      c = insert(:contest, round: 1)
      assert PerformanceView.predecessor_host_options(c) == []
    end
  end
end
