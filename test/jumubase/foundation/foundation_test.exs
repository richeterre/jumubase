defmodule Jumubase.FoundationTest do
  use Jumubase.DataCase
  alias Ecto.Changeset
  alias Jumubase.Accounts.User
  alias Jumubase.Foundation
  alias Jumubase.Foundation.{Category, Contest, ContestCategory, ContestSeed, Host, Stage}

  describe "list_hosts/0 " do
    test "returns all hosts ordered by current grouping and name" do
      h1 = insert(:host, current_grouping: "2")
      h2 = insert(:host, current_grouping: "1", name: "B")
      h3 = insert(:host, current_grouping: "3")
      h4 = insert(:host, current_grouping: "1", name: "A")

      assert Foundation.list_hosts() == [h4, h2, h1, h3]
    end
  end

  describe "list_hosts/1" do
    test "returns the hosts with the given ids" do
      [_h1, h2, h3] = insert_list(3, :host)
      assert Foundation.list_hosts([h2.id, h3.id]) == [h2, h3]
    end
  end

  describe "list_hosts_by_grouping/1" do
    test "returns the hosts that currently belong to the given grouping, sorted by name" do
      h1 = insert(:host, current_grouping: "1", name: "B")
      _h2 = insert(:host, current_grouping: "2")
      h3 = insert(:host, current_grouping: "1", name: "A")
      assert Foundation.list_hosts_by_grouping("1") == [h3, h1]
    end
  end

  describe "list_hosts_for_user/1" do
    test "returns the user's associated hosts" do
      hosts = insert_list(2, :host)
      u = insert(:user, hosts: hosts)

      # Non-matching data
      insert(:user, hosts: build_list(1, :host))

      assert_ids_match_unordered(Foundation.list_hosts_for_user(u), hosts)
    end
  end

  describe "list_performance_predecessor_hosts/1" do
    setup do
      [lw: insert(:contest, season: 56, round: 2)]
    end

    test "returns all hosts with successor performances in a given LW, ordered by name", %{lw: lw} do
      h1 = insert(:host, name: "C")
      h2 = insert(:host, name: "A")
      h3 = insert(:host, name: "B")

      insert_performance(lw, predecessor_host: h1)
      insert_performance(lw, predecessor_host: h2)
      insert_performance(lw, predecessor_host: h3)

      assert_ids_match_ordered(Foundation.list_performance_predecessor_hosts(lw), [h2, h3, h1])
    end

    test "does not return predecessor contest hosts without performances in the LW", %{lw: lw} do
      insert(:contest, season: lw.season, round: 1, grouping: lw.grouping)
      assert Foundation.list_performance_predecessor_hosts(lw) == []
    end
  end

  describe "get_host!/1" do
    test "returns a host" do
      host = insert(:host)
      assert Foundation.get_host!(host.id) == host
    end

    test "raises an error if the host isn't found" do
      assert_raise Ecto.NoResultsError, fn -> Foundation.get_host!(123) end
    end
  end

  describe "create_host/1" do
    test "creates a host with valid data" do
      params = params_for(:host, name: "X")
      assert {:ok, result} = Foundation.create_host(params)
      assert %Host{name: "X"} = result
    end

    test "returns an error changeset for invalid data" do
      params = params_for(:host, name: nil)
      assert {:error, %Changeset{}} = Foundation.create_host(params)
    end
  end

  describe "update_host/1" do
    test "updates a host with valid data" do
      host = insert(:host, name: "A")
      assert {:ok, result} = Foundation.update_host(host, %{name: "B"})
      assert result.name == "B"
    end

    test "returns an error changeset for invalid data" do
      host = insert(:host)
      assert {:error, %Ecto.Changeset{}} = Foundation.update_host(host, %{name: nil})
    end
  end

  describe "change_host/1" do
    test "returns a host changeset" do
      host = insert(:host)
      assert %Ecto.Changeset{} = Foundation.change_host(host)
    end
  end

  describe "country_codes/1" do
    test "returns an array with country codes for Israel/Palestine" do
      host = insert(:host, country_code: "IL/PS")
      assert Foundation.country_codes(host) == ~w(IL PS)
    end

    test "returns an array with a single country code otherwise" do
      host = insert(:host, country_code: "FI")
      assert Foundation.country_codes(host) == ~w(FI)
    end
  end

  describe "list_contests/0" do
    test "returns all contests" do
      contests = insert_list(2, :contest)
      assert Foundation.list_contests() == contests
    end

    test "orders contests by season, round, grouping, host name, and start date" do
      h1 = build(:host, current_grouping: "1", name: "A")
      h2 = build(:host, current_grouping: "2", name: "B")
      d1 = Timex.today()
      d2 = Timex.shift(d1, days: 1)

      c1 = insert(:contest, season: 56, round: 0, grouping: "2", host: h2)
      c2 = insert(:contest, season: 57, round: 0, grouping: "2", host: h2)
      c3 = insert(:contest, season: 56, round: 0, grouping: "1", host: h1)
      c4 = insert(:contest, season: 56, round: 1, grouping: "2", host: h2, start_date: d2)
      c5 = insert(:contest, season: 56, round: 1, grouping: "2", host: h2, start_date: d1)
      c6 = insert(:contest, season: 57, round: 1, grouping: "2", host: h2)
      c7 = insert(:contest, season: 56, round: 1, grouping: "1", host: h1)
      c8 = insert(:contest, season: 56, round: 2, grouping: "2", host: h2)
      c9 = insert(:contest, season: 57, round: 2, grouping: "2", host: h2)
      c10 = insert(:contest, season: 57, round: 2, grouping: "1", host: h1)
      c11 = insert(:contest, season: 56, round: 2, grouping: "1", host: h1)

      assert_ids_match_ordered(Foundation.list_contests(), [
        c10,
        c9,
        c6,
        c2,
        c11,
        c8,
        c7,
        c5,
        c4,
        c3,
        c1
      ])
    end

    test "preloads the contests' hosts" do
      insert(:contest)
      [result] = Foundation.list_contests()
      assert %Host{} = result.host
    end
  end

  describe "list_contests/1" do
    test "returns all contests matching the query" do
      [c1, _] = insert_list(2, :contest)
      query = from c in Contest, limit: 1
      assert Foundation.list_contests(query) == [c1]
    end

    test "preloads the contests' hosts" do
      insert(:contest)
      query = from c in Contest, limit: 1
      [result] = Foundation.list_contests(query)
      assert %Host{} = result.host
    end
  end

  describe "list_open_contests/1" do
    test "returns open RW contests, ordered by host name and start date" do
      d0 = Timex.today()
      d1 = Timex.shift(d0, days: 1)
      d2 = Timex.shift(d0, days: 2)

      c1 = insert(:contest, round: 1, host: build(:host, name: "B"), deadline: d0)
      c2 = insert(:contest, round: 1, host: build(:host, name: "A"), deadline: d1)
      c3 = insert(:contest, round: 1, host: build(:host, name: "C"), deadline: d0, start_date: d2)
      c4 = insert(:contest, round: 1, host: build(:host, name: "C"), deadline: d0, start_date: d1)

      assert Foundation.list_open_contests(1) == [c2, c1, c4, c3]
    end

    test "returns open Kimu contests, ordered by host name" do
      d0 = Timex.today()
      d1 = Timex.shift(d0, days: 1)

      c1 = insert(:contest, round: 0, host: build(:host, name: "B"), deadline: d0)
      c2 = insert(:contest, round: 0, host: build(:host, name: "A"), deadline: d1)
      c3 = insert(:contest, round: 0, host: build(:host, name: "C"), deadline: d1)

      assert Foundation.list_open_contests(0) == [c2, c1, c3]
    end

    test "returns open LW contests, ordered by host name" do
      d0 = Timex.today()
      d1 = Timex.shift(d0, days: 1)

      h1 = build(:host, current_grouping: "1", name: "B")
      h2 = build(:host, current_grouping: "2", name: "A")
      h3 = build(:host, current_grouping: "3", name: "C")

      c1 = insert(:contest, round: 2, grouping: "1", host: h1, deadline: d0)
      c2 = insert(:contest, round: 2, grouping: "2", host: h2, deadline: d1)
      c3 = insert(:contest, round: 2, grouping: "3", host: h3, deadline: d1)

      assert Foundation.list_open_contests(2) == [c2, c1, c3]
    end

    test "does not return contests that don't allow registration" do
      today = Timex.today()

      insert(:contest, round: 0, allows_registration: false, deadline: today)
      insert(:contest, round: 1, allows_registration: false, deadline: today)
      insert(:contest, round: 2, allows_registration: false, deadline: today)

      assert Foundation.list_open_contests(0) == []
      assert Foundation.list_open_contests(1) == []
      assert Foundation.list_open_contests(2) == []
    end

    test "does not return contests with a past signup deadline" do
      yesterday = Timex.today() |> Timex.shift(days: -1)

      insert(:contest, round: 0, deadline: yesterday)
      insert(:contest, round: 1, deadline: yesterday)
      insert(:contest, round: 2, deadline: yesterday)

      assert Foundation.list_open_contests(0) == []
      assert Foundation.list_open_contests(1) == []
      assert Foundation.list_open_contests(2) == []
    end
  end

  describe "list_public_contests/0" do
    test "returns all contests with public timetables and at least one staged performance" do
      %{stages: [s]} = host_with_stage = insert(:host, stages: build_list(1, :stage))

      # Matching contest
      c1 = insert_public_contest(host: host_with_stage)
      insert_performance(c1, stage: s)

      # No stages
      insert_public_contest(host: build(:host, stages: []))
      |> insert_performance

      # No performances
      insert_public_contest(host: host_with_stage)

      # No public timetables
      insert(:contest, host: host_with_stage, timetables_public: false)
      |> insert_performance(stage: s)

      assert_ids_match_unordered(Foundation.list_public_contests(), [c1])
    end

    test "orders the contest by start date, end date, round, and host name" do
      %{stages: [s1]} = h1 = insert(:host, name: "B", stages: build_list(1, :stage))
      %{stages: [s2]} = h2 = insert(:host, name: "A", stages: build_list(1, :stage))

      day0 = Timex.today()
      day1 = Timex.shift(day0, days: 1)
      day2 = Timex.shift(day0, days: 2)

      c1 = insert_public_contest(host: h1, start_date: day1, end_date: day1, round: 1)
      insert_performance(c1, stage: s1)
      c2 = insert_public_contest(host: h1, start_date: day1, end_date: day1, round: 0)
      insert_performance(c2, stage: s1)
      c3 = insert_public_contest(host: h2, start_date: day1, end_date: day1, round: 0)
      insert_performance(c3, stage: s2)
      c4 = insert_public_contest(host: h2, start_date: day1, end_date: day1, round: 1)
      insert_performance(c4, stage: s2)
      c5 = insert_public_contest(host: h1, start_date: day0, end_date: day1, round: 1)
      insert_performance(c5, stage: s1)
      c6 = insert_public_contest(host: h1, start_date: day0, end_date: day2, round: 1)
      insert_performance(c6, stage: s1)
      c7 = insert_public_contest(host: h1, start_date: day0, end_date: day1, round: 0)
      insert_performance(c7, stage: s1)
      c8 = insert_public_contest(host: h2, start_date: day0, end_date: day1, round: 0)
      insert_performance(c8, stage: s2)

      assert_ids_match_ordered(Foundation.list_public_contests(), [c4, c1, c3, c2, c6, c5, c8, c7])
    end

    test "preloads the contests' hosts with used stages, as well as non-empty contest categories" do
      [s1, s2, _s3] = stages = insert_list(3, :stage)
      host = insert(:host, stages: stages)
      c1 = insert_public_contest(host: host, contest_categories: [])
      c2 = insert_public_contest(host: host, contest_categories: [])
      cc1 = insert_contest_category(c1)
      insert_contest_category(c1)
      cc2 = insert_contest_category(c2)

      # Keep third stage (s3) unused
      insert_performance(cc1, stage: s1)
      insert_performance(cc1, stage: s2)
      insert_performance(cc2, stage: s2)

      [c1, c2] = Foundation.list_public_contests()

      assert %Contest{
               host: %Host{stages: c1_stages},
               contest_categories: [%ContestCategory{category: %Category{}}]
             } = c1

      assert_ids_match_unordered(c1_stages, [s1, s2])

      assert %Contest{
               host: %Host{stages: c2_stages},
               contest_categories: [%ContestCategory{category: %Category{}}]
             } = c2

      assert_ids_match_unordered(c2_stages, [s2])
    end

    test "orders preloaded host stages by insertion date" do
      now = Timex.now()
      h = insert(:host)
      c = insert_public_contest(host: h)
      s1 = insert(:stage, host: h, inserted_at: now)
      s2 = insert(:stage, host: h, inserted_at: now |> Timex.shift(seconds: 1))
      s3 = insert(:stage, host: h, inserted_at: now |> Timex.shift(seconds: -1))
      insert_performance(c, stage: s1)
      insert_performance(c, stage: s2)
      insert_performance(c, stage: s3)

      [result] = Foundation.list_public_contests()
      assert_ids_match_ordered(result.host.stages, [s3, s1, s2])
    end

    test "orders preloaded contest categories by insertion date" do
      now = Timex.now()
      s = insert(:stage, host: build(:host))
      c = insert_public_contest(host: s.host)
      cc1 = insert(:contest_category, contest: c, inserted_at: now)
      cc2 = insert(:contest_category, contest: c, inserted_at: now |> Timex.shift(seconds: 1))
      cc3 = insert(:contest_category, contest: c, inserted_at: now |> Timex.shift(seconds: -1))
      insert_performance(cc1, stage: s)
      insert_performance(cc2, stage: s)
      insert_performance(cc3, stage: s)

      [result] = Foundation.list_public_contests()
      assert_ids_match_ordered(result.contest_categories, [cc3, cc1, cc2])
    end
  end

  describe "list_featured_contests/1" do
    test "returns at most N featured contests in ascending date order" do
      %{stages: [s]} = h = insert(:host, stages: build_list(1, :stage))

      d0 = Timex.today()
      dm2 = Timex.shift(d0, days: -2)
      dm1 = Timex.shift(d0, days: -1)
      dp1 = Timex.shift(d0, days: 1)
      dp14 = Timex.shift(d0, days: 14)
      dp15 = Timex.shift(d0, days: 15)
      dp16 = Timex.shift(d0, days: 16)

      # Earliest matching contest
      c1 = insert_public_contest(host: h, start_date: dm2, end_date: dm1)

      # With these we test sorting by start *and* end date
      c2 = insert_public_contest(host: h, start_date: d0, end_date: dp1)
      c3 = insert_public_contest(host: h, start_date: d0, end_date: d0)

      # Latest matching contests
      c4 = insert_public_contest(host: h, start_date: dp14, end_date: dp15)
      c5 = insert_public_contest(host: h, start_date: dp14, end_date: dp16)

      insert_performance(c1, stage: s)
      insert_performance(c2, stage: s)
      insert_performance(c3, stage: s)
      insert_performance(c4, stage: s)
      insert_performance(c5, stage: s)

      # Not matching
      c6 = insert_public_contest(host: h, start_date: dm2, end_date: dm2)
      c7 = insert_public_contest(host: h, start_date: dp15, end_date: dp15)
      insert_performance(c6, stage: s)
      insert_performance(c7, stage: s)

      assert_ids_match_ordered(Foundation.list_featured_contests(4), [c1, c3, c2, c4])
    end
  end

  describe "list_latest_relevant_contests/2" do
    setup %{role: role} do
      [user: insert(:user, role: role)]
    end

    @tag role: "local-organizer"
    test "returns latest-season own contests to local organizers", %{user: u} do
      own_host = build(:host, users: [u])

      c1 = insert(:contest, season: 57, round: 0, host: own_host)
      c2 = insert(:contest, season: 57, round: 1, host: own_host)
      c3 = insert(:contest, season: 57, round: 2, host: own_host)

      # Earlier contests that should not be returned
      insert(:contest, season: 56, round: 0, host: own_host)
      insert(:contest, season: 56, round: 1, host: own_host)
      insert(:contest, season: 56, round: 2, host: own_host)

      assert_ids_match_unordered(
        Foundation.list_latest_relevant_contests(Contest, u),
        [c1, c2, c3]
      )
    end

    @tag role: "local-organizer"
    test "returns no foreign contests to local organizers", %{user: u} do
      insert(:contest, round: 0)
      insert(:contest, round: 1)
      insert(:contest, round: 2)

      assert Foundation.list_latest_relevant_contests(Contest, u) == []
    end

    for role <- roles_except("local-organizer") do
      @tag role: role
      test "returns latest own contests and foreign LW contests to #{role} users", %{user: u} do
        own_host = build(:host, current_grouping: "1", users: [u])
        c1 = insert(:contest, season: 57, round: 0, grouping: "1", host: own_host)
        c2 = insert(:contest, season: 57, round: 1, grouping: "1", host: own_host)
        c3 = insert(:contest, season: 57, round: 2, grouping: "1", host: own_host)
        c4 = insert(:contest, season: 57, round: 2, grouping: "2")

        # Earlier contests that should not be returned
        insert(:contest, season: 56, round: 0, grouping: "1", host: own_host)
        insert(:contest, season: 56, round: 1, grouping: "1", host: own_host)
        insert(:contest, season: 56, round: 2, grouping: "1", host: own_host)
        insert(:contest, season: 56, round: 2, grouping: "2")

        assert_ids_match_unordered(
          Foundation.list_latest_relevant_contests(Contest, u),
          [c1, c2, c3, c4]
        )
      end

      @tag role: role
      test "returns no foreign Kimu or RW contests to #{role} users", %{user: u} do
        insert(:contest, round: 0)
        insert(:contest, round: 1)

        assert Foundation.list_latest_relevant_contests(Contest, u) == []
      end
    end

    for role <- all_roles() do
      @tag role: role
      test "returns nothing if the latest season is above a #{role} user's own contests", %{
        user: u
      } do
        own_host = build(:host, users: [u])

        insert(:contest, season: 56, round: 2, host: own_host)
        insert(:contest, season: 57, round: 1)

        assert Foundation.list_latest_relevant_contests(Contest, u) == []
      end

      @tag role: role
      test "returns nothing to #{role} users if there are no contests", %{user: u} do
        assert Foundation.list_latest_relevant_contests(Contest, u) == []
      end
    end

    @tag role: "local-organizer"
    test "orders contests by round and host name", %{user: u} do
      h1 = insert(:host, current_grouping: "1", name: "A", users: [u])
      h2 = insert(:host, current_grouping: "2", name: "B", users: [u])

      c1 = insert(:contest, round: 0, grouping: "2", host: h2)
      c2 = insert(:contest, round: 0, grouping: "1", host: h1)
      c3 = insert(:contest, round: 1, grouping: "2", host: h2)
      c4 = insert(:contest, round: 1, grouping: "1", host: h1)
      c5 = insert(:contest, round: 2, grouping: "2", host: h2)
      c6 = insert(:contest, round: 2, grouping: "1", host: h1)

      assert_ids_match_ordered(
        Foundation.list_latest_relevant_contests(Contest, u),
        [c6, c5, c4, c3, c2, c1]
      )
    end

    @tag role: "local-organizer"
    test "preloads the contests' hosts", %{user: u} do
      insert(:contest, host: build(:host, users: [u]))
      [result] = Foundation.list_latest_relevant_contests(Contest, u)
      assert %Host{} = result.host
    end
  end

  describe "list_template_contests/3" do
    test "returns contests for the same round, 3 seasons back" do
      c1 = insert(:contest, season: 57, round: 1, grouping: "1")
      c2 = insert(:contest, season: 57, round: 1, grouping: "2")

      # Wrong round or not 3 seasons ago
      insert(:contest, season: 59, round: 1, grouping: "1")
      insert(:contest, season: 58, round: 1, grouping: "1")
      insert(:contest, season: 57, round: 2, grouping: "1")
      insert(:contest, season: 56, round: 1, grouping: "1")

      assert_ids_match_unordered(Foundation.list_template_contests(60, 1), [c1, c2])
    end
  end

  describe "count_contests/1" do
    test "returns the number of contests matching the query" do
      insert_list(2, :contest, round: 1)
      insert(:contest, round: 2)
      query = Contest |> where(round: 1)
      assert Foundation.count_contests(query) == 2
    end
  end

  describe "get_contest!/1" do
    test "returns a contest" do
      contest = insert(:contest)
      assert Foundation.get_contest!(contest.id) == contest
    end

    test "preloads the contest's host" do
      %{id: id} = insert(:contest)
      result = Foundation.get_contest!(id)
      assert %Host{} = result.host
    end

    test "raises an error if the contest isn't found" do
      assert_raise Ecto.NoResultsError, fn -> Foundation.get_contest!(123) end
    end
  end

  describe "get_public_contest/1" do
    test "returns a contest with public timetables" do
      %{id: id} = insert_public_contest()
      result = Foundation.get_public_contest(id)
      assert result.id == id
    end

    test "preloads the contest's host" do
      %{id: id} = insert_public_contest()
      assert %Contest{host: %Host{}} = Foundation.get_public_contest(id)
    end

    test "returns nil if the contest isn't found" do
      assert Foundation.get_public_contest(123) == nil
    end

    test "returns nil if the contest doesn't have public timetables" do
      %{id: id} = insert(:contest, timetables_public: false)
      assert Foundation.get_public_contest(id) == nil
    end
  end

  describe "get_public_contest!/1" do
    test "returns a contest with public timetables" do
      %{id: id} = insert_public_contest()
      result = Foundation.get_public_contest!(id)
      assert result.id == id
    end

    test "preloads the contest's host" do
      %{id: id} = insert_public_contest()
      assert %Contest{host: %Host{}} = Foundation.get_public_contest!(id)
    end

    test "raises an error if the contest isn't found" do
      assert_raise Ecto.NoResultsError, fn -> Foundation.get_public_contest!(123) end
    end

    test "raises an error if the contest doesn't have public timetables" do
      %{id: id} = insert(:contest, timetables_public: false)
      assert_raise Ecto.NoResultsError, fn -> Foundation.get_public_contest!(id) end
    end
  end

  describe "get_matching_kimu_contest/1" do
    setup do
      [host: insert(:host), season: 56]
    end

    test "returns a Kimu contest with the same season and host as a given RW contest", %{
      host: h,
      season: s
    } do
      kimu = insert(:contest, host: h, season: s, round: 0)
      rw = insert(:contest, host: h, season: s, round: 1)

      result = Foundation.get_matching_kimu_contest(rw)
      assert result.id == kimu.id
    end

    test "returns nil if the given contest is not an RW contest", %{host: h, season: s} do
      insert(:contest, host: h, season: s, round: 0)
      lw = insert(:contest, host: h, season: s, round: 2)

      assert Foundation.get_matching_kimu_contest(lw) == nil
    end

    test "returns nil if no matching Kimu contest exists", %{host: h, season: s} do
      # Wrong host
      insert(:contest, host: build(:host), season: s, round: 0)
      # Wrong season
      insert(:contest, host: h, season: s + 1, round: 0)
      # Wrong round
      insert(:contest, host: h, season: s, round: 2)
      rw = insert(:contest, host: h, season: s, round: 1)

      assert Foundation.get_matching_kimu_contest(rw) == nil
    end
  end

  describe "get_successor/1" do
    test "returns the next-round (LW) successor for an RW contest" do
      c1 = insert(:contest, season: 56, round: 1, grouping: "1")
      # Irrelevant contests
      insert(:contest, season: 57, round: 2, grouping: "1")
      insert(:contest, season: 56, round: 0, grouping: "1")
      insert(:contest, season: 56, round: 1, grouping: "1")
      insert(:contest, season: 56, round: 2, grouping: "2")
      # Successor contest
      c2 = insert(:contest, season: 56, round: 2, grouping: "1")

      result = Foundation.get_successor(c1)
      assert result.id == c2.id
    end

    test "preloads the necessary associations" do
      c = insert(:contest, season: 56, round: 1)
      insert(:contest, season: 56, round: 2)

      assert %Contest{host: %Host{}} = Foundation.get_successor(c)
    end

    test "returns nil if there is no matching LW" do
      c = insert(:contest, season: 56, round: 1)
      assert Foundation.get_successor(c) == nil
    end

    test "returns nil for non-RW contests" do
      c1 = insert(:contest, season: 56, round: 0)
      c2 = insert(:contest, season: 56, round: 2)
      assert Foundation.get_successor(c1) == nil
      assert Foundation.get_successor(c2) == nil
    end
  end

  describe "get_latest_official_contest/1" do
    test "returns the latest-ending non-Kimu contest" do
      today = Timex.today()
      insert(:contest, round: 1, end_date: today)
      %{id: id} = insert(:contest, round: 1, end_date: today |> Timex.shift(days: 1))
      insert(:contest, round: 0, end_date: today |> Timex.shift(days: 2))
      insert(:contest, round: 1, end_date: today |> Timex.shift(days: -1))

      assert %Contest{id: ^id} = Foundation.get_latest_official_contest()
    end

    test "preloads the contest host" do
      insert(:contest)
      assert %Contest{host: %Host{}} = Foundation.get_latest_official_contest()
    end
  end

  describe "create_contests/2" do
    test "creates one contest per host for valid seed data" do
      seed = %ContestSeed{
        season: 56,
        round: 1,
        contest_categories: [
          build(:contest_category, category: build(:category, name: "Violine solo"))
        ]
      }

      [h1, h2] = [insert(:host, name: "A"), insert(:host, name: "B")]

      assert {:ok, result} = Foundation.create_contests(seed, [h1, h2])

      assert %Contest{season: 56, round: 1, contest_categories: [cc1]} = result[h1.id]
      assert %ContestCategory{category: %{name: "Violine solo"}} = cc1

      assert %Contest{season: 56, round: 1, contest_categories: [cc2]} = result[h2.id]
      assert %ContestCategory{category: %{name: "Violine solo"}} = cc2
    end

    test "keeps registration closed for newly created contests by default" do
      kimu_seed = %ContestSeed{season: 56, round: 0}
      rw_seed = %ContestSeed{season: 56, round: 1}
      lw_seed = %ContestSeed{season: 56, round: 2}

      h = insert(:host)

      {:ok, kimu_contests} = Foundation.create_contests(kimu_seed, [h])
      {:ok, rw_contests} = Foundation.create_contests(rw_seed, [h])
      {:ok, lw_contests} = Foundation.create_contests(lw_seed, [h])

      assert %Contest{allows_registration: false} = kimu_contests[h.id]
      assert %Contest{allows_registration: false} = rw_contests[h.id]
      assert %Contest{allows_registration: false} = lw_contests[h.id]
    end

    test "returns an error changeset for invalid seed data" do
      seed = %ContestSeed{season: -1, round: 1}
      %{id: h_id} = h = insert(:host)

      assert {:error, ^h_id, %Changeset{}, %{}} = Foundation.create_contests(seed, [h])
    end
  end

  describe "update_contest/1" do
    test "updates a contest with valid data" do
      contest = insert(:contest, season: 56)
      assert {:ok, result} = Foundation.update_contest(contest, %{season: 57})
      assert result.season == 57
    end

    test "returns an error changeset for invalid data" do
      contest = insert(:contest)
      assert {:error, %Ecto.Changeset{}} = Foundation.update_contest(contest, %{season: nil})
    end
  end

  describe "change_contest/1" do
    test "returns a contest changeset" do
      contest = insert(:contest)
      assert %Ecto.Changeset{} = Foundation.change_contest(contest)
    end
  end

  describe "delete_contest!/1" do
    test "deletes a contest" do
      contest = insert(:contest)
      assert contest = Foundation.delete_contest!(contest)
      refute Repo.get(Contest, contest.id)
    end

    test "raises an error if the contest no longer exists" do
      contest = insert(:contest)
      Repo.delete(contest)

      assert_raise Ecto.StaleEntryError, fn ->
        Foundation.delete_contest!(contest)
      end
    end
  end

  describe "date_range/1" do
    test "returns the date range on which the contest takes place" do
      start_date = ~D[2019-01-01]
      end_date = ~D[2019-01-03]
      contest = insert(:contest, start_date: start_date, end_date: end_date)
      assert %Date.Range{first: ^start_date, last: ^end_date} = Foundation.date_range(contest)
    end
  end

  describe "list_categories/0" do
    test "returns all categories, ordered by type, genre and name" do
      cg1 = insert(:category, type: "ensemble", genre: "popular")
      cg2 = insert(:category, type: "ensemble", genre: "kimu")
      cg3 = insert(:category, type: "ensemble", genre: "classical", name: "B")
      cg4 = insert(:category, type: "ensemble", genre: "classical", name: "A")

      cg5 = insert(:category, type: "solo_or_ensemble", genre: "popular")
      cg6 = insert(:category, type: "solo_or_ensemble", genre: "kimu")
      cg7 = insert(:category, type: "solo_or_ensemble", genre: "classical", name: "B")
      cg8 = insert(:category, type: "solo_or_ensemble", genre: "classical", name: "A")

      cg9 = insert(:category, type: "solo", genre: "popular")
      cg10 = insert(:category, type: "solo", genre: "kimu")
      cg11 = insert(:category, type: "solo", genre: "classical", name: "B")
      cg12 = insert(:category, type: "solo", genre: "classical", name: "A")

      assert_ids_match_ordered(
        Foundation.list_categories(),
        [cg8, cg7, cg6, cg5, cg12, cg11, cg10, cg9, cg4, cg3, cg2, cg1]
      )
    end
  end

  describe "get_category!/1" do
    test "returns a category" do
      %{id: id} = insert(:category)
      assert %Category{id: ^id} = Foundation.get_category!(id)
    end

    test "raises an error if no category can be found" do
      assert_raise Ecto.NoResultsError, fn -> Foundation.get_category!(1) end
    end
  end

  describe "create_category/1" do
    test "creates a category with valid data" do
      params = params_for(:category, name: "X")
      assert {:ok, result} = Foundation.create_category(params)
      assert %Category{name: "X"} = result
    end

    test "returns an error changeset for invalid data" do
      params = params_for(:category, name: "")
      assert {:error, %Changeset{}} = Foundation.create_category(params)
    end
  end

  describe "update_category/1" do
    setup do
      [category: insert(:category, name: "X")]
    end

    test "updates a category with valid data", %{category: cg} do
      params = params_for(:category, name: "Y")
      assert {:ok, result} = Foundation.update_category(cg, params)
      assert %Category{name: "Y"} = result
    end

    test "returns an error changeset for invalid data", %{category: cg} do
      params = params_for(:category, name: "")
      assert {:error, %Changeset{}} = Foundation.update_category(cg, params)
    end
  end

  describe "change_category/1" do
    test "returns a category changeset" do
      category = insert(:category)
      assert %Ecto.Changeset{} = Foundation.change_category(category)
    end
  end

  describe "list_contest_categories/1" do
    test "returns all contest categories of the given contest in insertion order" do
      c = insert(:contest)
      cc1 = insert_contest_category(c)
      cc2 = insert_contest_category(c)

      assert_ids_match_ordered(
        Foundation.list_contest_categories(c),
        [cc1, cc2]
      )
    end

    test "preloads the contest categories' categories" do
      c = insert(:contest, contest_categories: build_list(1, :contest_category))
      assert [result] = Foundation.list_contest_categories(c)
      assert %Category{} = result.category
    end
  end

  describe "get_contest_category!/2" do
    setup do
      [contest: insert(:contest)]
    end

    test "returns a contest category", %{contest: c} do
      %{id: id} = insert_contest_category(c)
      assert %ContestCategory{id: ^id} = Foundation.get_contest_category!(c, id)
    end

    test "raises an error if the contest category isn't in the given contest", %{contest: c} do
      %{id: id} = insert_contest_category(build(:contest))
      assert_raise Ecto.NoResultsError, fn -> Foundation.get_contest_category!(c, id) end
    end
  end

  describe "get_stage!/1" do
    setup do
      [contest: insert(:contest)]
    end

    test "returns a contest stage", %{contest: c} do
      %{id: id} = insert(:stage, host: c.host)
      assert %Stage{id: ^id} = Foundation.get_stage!(c, id)
    end

    test "raises an error if the stage isn't owned by the given contest's host", %{contest: c} do
      %{id: id} = insert(:stage, host: build(:host))
      assert_raise Ecto.NoResultsError, fn -> Foundation.get_stage!(c, id) end
    end
  end

  describe "load_host_users/1" do
    test "preloads a contest's host with associated users" do
      %{id: id} =
        insert(:contest,
          host:
            build(:host,
              users: [
                build(:user, given_name: "A"),
                build(:user, given_name: "B")
              ]
            )
        )

      contest = Repo.get(Contest, id) |> Foundation.load_host_users()
      assert [%User{given_name: "A"}, %User{given_name: "B"}] = contest.host.users
    end
  end

  test "load_contest_categories/1 preloads a contest's contest categories in insertion order" do
    %{id: id} =
      insert(:contest,
        contest_categories: [
          build(:contest_category, category: build(:category, name: "First")),
          build(:contest_category, category: build(:category, name: "Second"))
        ]
      )

    contest = Repo.get(Contest, id) |> Foundation.load_contest_categories()

    assert [
             %ContestCategory{category: %Category{name: "First"}},
             %ContestCategory{category: %Category{name: "Second"}}
           ] = contest.contest_categories
  end

  test "load_available_stages/1 preloads a contest's available stages" do
    %{id: id} =
      insert(:contest,
        host: build(:host, stages: build_list(1, :stage, name: "X"))
      )

    contest = Repo.get(Contest, id) |> Foundation.load_available_stages()
    assert [%Stage{name: "X"}] = contest.host.stages
  end

  test "load_used_stages/1 preloads a contest's used stages in insertion order" do
    now = Timex.now()
    [s1, s2] = insert_list(2, :stage, inserted_at: now)
    s3 = insert(:stage, inserted_at: now |> Timex.shift(seconds: 1))
    s4 = insert(:stage, inserted_at: now |> Timex.shift(seconds: -1))
    c = insert(:contest, host: build(:host, stages: [s1, s2, s3, s4]))
    insert_performance(c, stage: s2)
    insert_performance(c, stage: s3)
    insert_performance(c, stage: s4)

    contest = Repo.get(Contest, c.id) |> Foundation.load_used_stages()
    assert_ids_match_ordered(contest.host.stages, [s4, s2, s3])
  end
end
