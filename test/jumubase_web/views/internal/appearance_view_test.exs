defmodule JumubaseWeb.AppearanceViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.Internal.AppearanceView

  test "instrument_name/1 returns an instrument's display name" do
    assert AppearanceView.instrument_name("piano") == "Piano"
  end

  test "acc/1 returns only accompanist appearances" do
    [sol, ens, _acc] = appearances = role_appearances()
    assert AppearanceView.non_acc(appearances) == [sol, ens]
  end
  
  test "non_acc/1 returns only soloist + ensemblist appearances" do
    [_sol, _ens, acc] = appearances = role_appearances()
    assert AppearanceView.acc(appearances) == [acc]
  end

  # Private helpers

  defp role_appearances do
    sol = build(:appearance, participant_role: "soloist")
    ens = build(:appearance, participant_role: "ensemblist")
    acc = build(:appearance, participant_role: "accompanist")
    [sol, ens, acc]
  end
end
