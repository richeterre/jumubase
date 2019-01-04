defmodule JumubaseWeb.Internal.AppearanceViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.Internal.AppearanceView

  test "appearance_info/1 returns the participant's full name and instrument name" do
    a = build(:appearance,
      participant: build(:participant, given_name: "A", family_name: "B"),
      instrument: "piano"
    )
    assert AppearanceView.appearance_info(a) == "A B, Piano"
  end

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
    sol = build(:appearance, role: "soloist")
    ens = build(:appearance, role: "ensemblist")
    acc = build(:appearance, role: "accompanist")
    [sol, ens, acc]
  end
end
