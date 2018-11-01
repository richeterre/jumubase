defmodule JumubaseWeb.Internal.ContestViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.Internal.ContestView

  describe "name_with_flag/1" do
    test "returns a display name for a Kimu contest" do
      contest = build(:contest,
        season: 55,
        round: 0,
        host: build(:host, country_code: "FI", name: "DS Helsinki")
      )
      assert ContestView.name_with_flag(contest) == "🇫🇮 DS Helsinki, Kimu 2018"
    end

    test "returns a display name for an RW contest" do
      contest = build(:contest,
        season: 55,
        round: 1,
        host: build(:host, country_code: "FI", name: "DS Helsinki")
      )
      assert ContestView.name_with_flag(contest) == "🇫🇮 DS Helsinki, RW 2018"
    end

    test "uses an EU flag for a LW contest" do
      contest = build(:contest,
        season: 55,
        round: 2,
        host: build(:host, country_code: "FI", name: "DS Helsinki")
      )
      assert ContestView.name_with_flag(contest) == "🇪🇺 DS Helsinki, LW 2018"
    end
  end

  describe "deadline_info/2" do
    test "returns formatted deadline info if the contest deadline differs from the general one" do
      contest = build(:contest, deadline: ~D[2018-12-14])
      assert ContestView.deadline_info(contest, ~D[2018-12-15]) ==
        {:safe, "(Deadline: <strong>14 December</strong>)"}
    end

    test "returns nothing if the contest has the general deadline" do
      contest = build(:contest, deadline: ~D[2018-12-15])
      assert ContestView.deadline_info(contest, ~D[2018-12-15]) == nil
    end
  end

  describe "dates/1" do
    test "returns a formatted date range for a multi-day contest" do
      contest = build(:contest,
        start_date: ~D[2019-01-01],
        end_date: ~D[2019-01-02]
      )
      assert ContestView.dates(contest) == "1 January 2019 – 2 January 2019"
    end

    test "returns a single formatted date for a single-day contest" do
      contest = build(:contest,
        start_date: ~D[2019-01-01],
        end_date: ~D[2019-01-01]
      )
      assert ContestView.dates(contest) == "1 January 2019"
    end
  end

  describe "format_date/1" do
    test "formats a date for display to the user" do
      assert ContestView.format_date(~D[2018-12-15]) == "15 December 2018"
    end

    test "returns nil if nil is passed for the date" do
      assert ContestView.format_date(nil) == nil
    end
  end

  describe "format_date/2" do
    test "formats a date in full style" do
      assert ContestView.format_date(~D[2018-12-15], :full) == "15 December 2018"
    end

    test "formats a date in medium style" do
      assert ContestView.format_date(~D[2018-12-15], :medium) == "15 December"
    end

    test "returns nil if nil is passed for the date" do
      assert ContestView.format_date(nil, :full) == nil
    end
  end
end
