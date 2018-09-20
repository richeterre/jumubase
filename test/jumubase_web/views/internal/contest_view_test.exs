defmodule JumubaseWeb.ContestViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.Internal.ContestView

  test "contest_name/1 returns a display name for a contest" do
    contest = build(:contest,
      season: 55,
      round: 1,
      host: build(:host, country_code: "FI", name: "DS Helsinki")
    )
    assert ContestView.contest_name(contest) == "🇫🇮 DS Helsinki, RW 2018"
  end
end
