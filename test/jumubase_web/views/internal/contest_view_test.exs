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

  test "contest_dates/1 returns a formatted date range for a multi-day contest" do
    contest = build(:contest,
      start_date: ~D[2019-01-01],
      end_date: ~D[2019-01-02]
    )
    assert ContestView.contest_dates(contest) == "1 Jan 2019 – 2 Jan 2019"
  end

  test "contest_dates/1 returns a single formatted date for a single-day contest" do
    contest = build(:contest,
      start_date: ~D[2019-01-01],
      end_date: ~D[2019-01-01]
    )
    assert ContestView.contest_dates(contest) == "1 Jan 2019"
  end

  test "format_date/1 formats a date for display to the user" do
    assert ContestView.format_date(~D[2018-12-15]) == "15 Dec 2018"
  end
end
