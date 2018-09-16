defmodule JumubaseWeb.PageViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.PageView

  test "contest_name/1 returns a display name for a contest" do
    contest = build(:contest,
      season: 55,
      round: 1,
      host: build(:host, name: "DS Helsinki")
    )
    assert PageView.contest_name(contest) == "DS Helsinki, RW 2018"
  end
end
