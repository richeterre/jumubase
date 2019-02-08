defmodule Jumubase.FoundationTest do
  use Jumubase.DataCase
  alias Ecto.Changeset
  alias Jumubase.Accounts.User
  alias Jumubase.Foundation
  alias Jumubase.Foundation.{Category, Contest, ContestCategory, Host, Stage}

  describe "list_hosts/0 " do
    test "returns all hosts" do
      host = insert(:host)
      assert Foundation.list_hosts() == [host]
    end
  end

  describe "list_hosts/1" do
    test "returns the hosts with the given ids" do
      [_h1, h2, h3] = insert_list(3, :host)
      assert Foundation.list_hosts([h2.id, h3.id]) == [h2, h3]
    end
  end

  describe "list_host_locations/0" do
    test "returns the hosts' locations" do
      h1 = insert(:host, latitude: 50.5, longitude: 10.0)
      h2 = insert(:host, latitude: 25.0, longitude: 50.5)

      assert Foundation.list_host_locations() == [
               {h1.latitude, h1.longitude},
               {h2.latitude, h2.longitude}
             ]
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

  describe "list_contests/0" do
    test "returns all contests" do
      contests = insert_list(2, :contest)
      assert Foundation.list_contests() == contests
    end

    test "orders contests by round and host name" do
      h1 = build(:host, name: "A")
      h2 = build(:host, name: "B")
      c1 = insert(:contest, round: 0, host: h2)
      c2 = insert(:contest, round: 0, host: h1)
      c3 = insert(:contest, round: 1, host: h2)
      c4 = insert(:contest, round: 1, host: h1)
      c5 = insert(:contest, round: 2, host: h2)
      c6 = insert(:contest, round: 2, host: h1)
      assert_ids_match_ordered(Foundation.list_contests(), [c6, c5, c4, c3, c2, c1])
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
    test "returns open RW contests, ordered by host name" do
      today = Timex.today()
      tomorrow = Timex.today() |> Timex.shift(days: 1)

      c1 = insert(:contest, round: 1, host: build(:host, name: "B"), deadline: today)
      c2 = insert(:contest, round: 1, host: build(:host, name: "A"), deadline: tomorrow)
      c3 = insert(:contest, round: 1, host: build(:host, name: "C"), deadline: tomorrow)

      assert Foundation.list_open_contests(1) == [c2, c1, c3]
    end

    test "returns open Kimu contests, ordered by host name" do
      today = Timex.today()
      tomorrow = Timex.today() |> Timex.shift(days: 1)

      c1 = insert(:contest, round: 0, host: build(:host, name: "B"), deadline: today)
      c2 = insert(:contest, round: 0, host: build(:host, name: "A"), deadline: tomorrow)
      c3 = insert(:contest, round: 0, host: build(:host, name: "C"), deadline: tomorrow)

      assert Foundation.list_open_contests(0) == [c2, c1, c3]
    end

    test "returns open LW contests, ordered by host name" do
      today = Timex.today()
      tomorrow = Timex.today() |> Timex.shift(days: 1)

      c1 = insert(:contest, round: 2, host: build(:host, name: "B"), deadline: today)
      c2 = insert(:contest, round: 2, host: build(:host, name: "A"), deadline: tomorrow)
      c3 = insert(:contest, round: 2, host: build(:host, name: "C"), deadline: tomorrow)

      assert Foundation.list_open_contests(2) == [c2, c1, c3]
    end

    test "does not return contests with a past signup deadline" do
      yesterday = Timex.today() |> Timex.shift(days: -1)
      insert(:contest, round: 0, deadline: yesterday)
      insert(:contest, round: 1, deadline: yesterday)

      assert Foundation.list_open_contests(0) == []
      assert Foundation.list_open_contests(1) == []
    end
  end

  describe "list_public_contests/1" do
    test "returns all contests with public timetables and at least one staged performance" do
      %{stages: [s]} = host_with_stage = insert(:host, stages: build_list(1, :stage))

      # Matching contest
      c1 = insert(:contest, host: host_with_stage, timetables_public: true)
      insert_performance(c1, stage: s)

      # No stages
      insert(:contest, host: build(:host, stages: []), timetables_public: true)
      |> insert_performance

      # No performances
      insert(:contest, host: host_with_stage, timetables_public: true)

      # No public timetables
      insert(:contest, host: host_with_stage, timetables_public: false)
      |> insert_performance(stage: s)

      assert_ids_match_unordered(Foundation.list_public_contests(), [c1])
    end

    test "orders the contest by round, then host name" do
      %{stages: [s1]} = h1 = insert(:host, name: "B", stages: build_list(1, :stage))
      %{stages: [s2]} = h2 = insert(:host, name: "A", stages: build_list(1, :stage))

      c1 = insert(:contest, host: h1, round: 1, timetables_public: true)
      insert_performance(c1, stage: s1)
      c2 = insert(:contest, host: h1, round: 0, timetables_public: true)
      insert_performance(c2, stage: s1)
      c3 = insert(:contest, host: h2, round: 0, timetables_public: true)
      insert_performance(c3, stage: s2)
      c4 = insert(:contest, host: h2, round: 1, timetables_public: true)
      insert_performance(c4, stage: s2)

      assert_ids_match_ordered(Foundation.list_public_contests(), [c4, c1, c3, c2])
    end

    test "preloads the contests' hosts with used stages, as well as non-empty contest categories" do
      [s1, s2, _s3] = stages = insert_list(3, :stage)
      host = insert(:host, stages: stages)
      c1 = insert(:contest, host: host, contest_categories: [], timetables_public: true)
      c2 = insert(:contest, host: host, contest_categories: [], timetables_public: true)
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

    test "orders preloaded contest categories by insertion date" do
      now = Timex.now()
      s = insert(:stage, host: build(:host))
      c = insert(:contest, host: s.host, timetables_public: true)
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

  describe "list_relevant_contests/2" do
    setup %{role: role} do
      [user: insert(:user, role: role)]
    end

    @tag role: "local-organizer"
    test "returns all own contests to local organizers", %{user: u} do
      own_host = build(:host, users: [u])

      own_kimu = insert(:contest, round: 0, host: own_host)
      own_rw = insert(:contest, round: 1, host: own_host)
      own_lw = insert(:contest, round: 2, host: own_host)

      assert_ids_match_unordered(
        Foundation.list_relevant_contests(Contest, u),
        [own_kimu, own_rw, own_lw]
      )
    end

    @tag role: "local-organizer"
    test "does not return any foreign contests to local organizers", %{user: u} do
      insert(:contest, round: 0)
      insert(:contest, round: 1)
      insert(:contest, round: 2)

      assert Foundation.list_relevant_contests(Contest, u) == []
    end

    for role <- roles_except("local-organizer") do
      @tag role: role
      test "returns all own contests and foreign LW contests to #{role} users", %{user: u} do
        own_host = build(:host, users: [u])
        c1 = insert(:contest, round: 0, host: own_host)
        c2 = insert(:contest, round: 1, host: own_host)
        c3 = insert(:contest, round: 2, host: own_host)
        c4 = insert(:contest, round: 2)

        assert_ids_match_unordered(
          Foundation.list_relevant_contests(Contest, u),
          [c1, c2, c3, c4]
        )
      end

      @tag role: role
      test "returns no foreign Kimu or RW contests to #{role} users", %{user: u} do
        insert(:contest, round: 0)
        insert(:contest, round: 1)

        assert Foundation.list_relevant_contests(Contest, u) == []
      end
    end

    @tag role: "local-organizer"
    test "orders contests by round and host name", %{user: u} do
      h1 = insert(:host, name: "A", users: [u])
      h2 = insert(:host, name: "B", users: [u])

      c1 = insert(:contest, round: 0, host: h2)
      c2 = insert(:contest, round: 0, host: h1)
      c3 = insert(:contest, round: 1, host: h2)
      c4 = insert(:contest, round: 1, host: h1)
      c5 = insert(:contest, round: 2, host: h2)
      c6 = insert(:contest, round: 2, host: h1)

      assert_ids_match_ordered(
        Foundation.list_relevant_contests(Contest, u),
        [c6, c5, c4, c3, c2, c1]
      )
    end

    @tag role: "local-organizer"
    test "preloads the contests' hosts", %{user: u} do
      insert(:contest, host: build(:host, users: [u]))
      [result] = Foundation.list_relevant_contests(Contest, u)
      assert %Host{} = result.host
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

  describe "get_public_contest!/1" do
    test "returns a contest with public timetables" do
      %{id: id} = insert(:contest, timetables_public: true)
      result = Foundation.get_public_contest!(id)
      assert result.id == id
    end

    test "preloads the contest's host" do
      %{id: id} = insert(:contest, timetables_public: true)
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
      c1 = insert(:contest, season: 56, round: 1)
      # Irrelevant contests
      insert(:contest, season: 56, round: 0)
      insert(:contest, season: 56, round: 1)
      insert(:contest, season: 57, round: 2)
      # Successor contest
      c2 = insert(:contest, season: 56, round: 2)

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

    test "raises an error if there are multiple results" do
      c = insert(:contest, season: 56, round: 1)
      insert(:contest, season: 56, round: 2)
      insert(:contest, season: 56, round: 2)

      assert_raise Ecto.MultipleResultsError, fn -> Foundation.get_successor(c) end
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

  describe "date_range/1" do
    test "returns the date range on which the contest takes place" do
      start_date = ~D[2019-01-01]
      end_date = ~D[2019-01-03]
      contest = insert(:contest, start_date: start_date, end_date: end_date)
      assert %Date.Range{first: ^start_date, last: ^end_date} = Foundation.date_range(contest)
    end
  end

  describe "general_deadline/1" do
    test "returns the deadline most common in the given contests" do
      [d1, d2, d3] = [~D[2018-12-01], ~D[2018-12-21], ~D[2018-12-15]]

      contests = [
        build(:contest, deadline: d1),
        build(:contest, deadline: d3),
        build(:contest, deadline: d1),
        build(:contest, deadline: d3),
        build(:contest, deadline: d2),
        build(:contest, deadline: d3)
      ]

      assert Foundation.general_deadline(contests) == d3
    end

    test "returns the earliest deadline if several are most common" do
      [d1, d2, d3] = [~D[2018-12-15], ~D[2018-12-01], ~D[2018-12-21]]

      contests = [
        build(:contest, deadline: d1),
        build(:contest, deadline: d2),
        build(:contest, deadline: d3),
        build(:contest, deadline: d3),
        build(:contest, deadline: d2),
        build(:contest, deadline: d1)
      ]

      assert Foundation.general_deadline(contests) == d2
    end
  end

  describe "list_categories/0" do
    test "returns all categories" do
      categories = insert_list(2, :category)
      assert Foundation.list_categories() == categories
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
    test "returns all contest categories of the given contest" do
      c = insert(:contest, contest_categories: build_list(2, :contest_category))

      assert_ids_match_unordered(
        Foundation.list_contest_categories(c),
        c.contest_categories
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

    test "preloads the contest category's associated category", %{contest: c} do
      %{id: id} = insert_contest_category(c)

      assert %ContestCategory{
               category: %Category{}
             } = Foundation.get_contest_category!(c, id)
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

  test "load_contest_categories/1 preloads a contest's contest categories" do
    %{id: id} =
      insert(:contest,
        contest_categories:
          build_list(1, :contest_category, category: build(:category, name: "ABC"))
      )

    contest = Repo.get(Contest, id) |> Foundation.load_contest_categories()
    assert [%ContestCategory{category: %Category{name: "ABC"}}] = contest.contest_categories
  end

  test "load_available_stages/1 preloads a contest's available stages" do
    %{id: id} =
      insert(:contest,
        host: build(:host, stages: build_list(1, :stage, name: "X"))
      )

    contest = Repo.get(Contest, id) |> Foundation.load_available_stages()
    assert [%Stage{name: "X"}] = contest.host.stages
  end

  test "load_used_stages/1 preloads a contest's used stages" do
    [s1, s2] = insert_list(2, :stage)
    c = insert(:contest, host: build(:host, stages: [s1, s2]))
    insert_performance(c, stage: s1)

    contest = Repo.get(Contest, c.id) |> Foundation.load_used_stages()
    assert_ids_match_unordered(contest.host.stages, [s1])
  end
end
