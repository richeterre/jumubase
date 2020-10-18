defmodule JumubaseWeb.Internal.ContestViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.Internal.ContestView

  @host build(:host, country_code: "FI", name: "Helsinki")

  describe "name/1" do
    test "returns a name for a Kimu contest" do
      contest = build(:contest, season: 55, round: 0, host: @host)
      assert ContestView.name(contest) == "Kimu Helsinki 2018"
    end

    test "returns a name for an RW contest" do
      contest = build(:contest, season: 55, round: 1, host: @host)
      assert ContestView.name(contest) == "RW Helsinki 2018"
    end

    test "returns a name for an LW contest" do
      contest = build(:contest, season: 55, round: 2, host: @host)
      assert ContestView.name(contest) == "LW Helsinki 2018"
    end
  end

  describe "flag/1" do
    test "returns a flag emoji for the contest" do
      contest = build(:contest, host: @host)
      assert ContestView.flag(contest) == "🇫🇮"
    end
  end

  describe "name_with_flag/1" do
    test "returns a display name for a Kimu contest" do
      contest = build(:contest, season: 55, round: 0, host: @host)
      assert ContestView.name_with_flag(contest) == "🇫🇮 Kimu Helsinki 2018"
    end

    test "returns a display name for an RW contest" do
      contest = build(:contest, season: 55, round: 1, host: @host)
      assert ContestView.name_with_flag(contest) == "🇫🇮 RW Helsinki 2018"
    end

    test "returns a display name for an LW contest" do
      contest = build(:contest, season: 55, round: 2, host: @host)
      assert ContestView.name_with_flag(contest) == "🇫🇮 LW Helsinki 2018"
    end
  end

  describe "dates/1" do
    test "returns a formatted date range for a multi-day contest" do
      contest = build(:contest, start_date: ~D[2019-01-01], end_date: ~D[2019-01-02])
      assert ContestView.dates(contest) == "1 January 2019 – 2 January 2019"
    end

    test "returns a single formatted date for a single-day contest" do
      contest = build(:contest, start_date: ~D[2019-01-01], end_date: ~D[2019-01-01])
      assert ContestView.dates(contest) == "1 January 2019"
    end
  end

  describe "year/1" do
    test "returns a contest's year based on the season" do
      contest = build(:contest, season: 56, start_date: ~D[2018-12-20], end_date: ~D[2018-12-20])
      assert ContestView.year(contest) == 2019
    end
  end

  describe "schedule_link_path/2" do
    test "returns a direct link to the stage scheduler if the contest has only one stage" do
      s = insert(:stage)
      c = insert(:contest, host: build(:host, stages: [s]))
      conn = build_conn()

      assert ContestView.schedule_link_path(conn, c) ==
               Routes.internal_contest_stage_schedule_path(conn, :schedule, c, s)
    end

    test "returns a link to the stage selection if the contest has many stages" do
      c = insert(:contest, host: build(:host, stages: build_list(2, :stage)))
      conn = build_conn()

      assert ContestView.schedule_link_path(conn, c) ==
               Routes.internal_contest_stage_path(conn, :index, c)
    end
  end
end
