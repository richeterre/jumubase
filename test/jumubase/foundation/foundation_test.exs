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
      assert Foundation.list_host_locations == [
        {h1.latitude, h1.longitude},
        {h2.latitude, h2.longitude},
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
      assert Foundation.list_contests == contests
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
      assert_ids_match_ordered Foundation.list_contests, [c6, c5, c4, c3, c2, c1]
    end

    test "preloads the contests' hosts" do
      insert(:contest)
      [result] = Foundation.list_contests
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
      today = Timex.today
      tomorrow = Timex.today |> Timex.shift(days: 1)

      c1 = insert(:contest, round: 1, host: build(:host, name: "B"), deadline: today)
      c2 = insert(:contest, round: 1, host: build(:host, name: "A"), deadline: tomorrow)
      c3 = insert(:contest, round: 1, host: build(:host, name: "C"), deadline: tomorrow)

      assert Foundation.list_open_contests(1) == [c2, c1, c3]
    end

    test "returns open Kimu contests, ordered by host name" do
      today = Timex.today
      tomorrow = Timex.today |> Timex.shift(days: 1)

      c1 = insert(:contest, round: 0, host: build(:host, name: "B"), deadline: today)
      c2 = insert(:contest, round: 0, host: build(:host, name: "A"), deadline: tomorrow)
      c3 = insert(:contest, round: 0, host: build(:host, name: "C"), deadline: tomorrow)

      assert Foundation.list_open_contests(0) == [c2, c1, c3]
    end

    test "returns open LW contests, ordered by host name" do
      today = Timex.today
      tomorrow = Timex.today |> Timex.shift(days: 1)

      c1 = insert(:contest, round: 2, host: build(:host, name: "B"), deadline: today)
      c2 = insert(:contest, round: 2, host: build(:host, name: "A"), deadline: tomorrow)
      c3 = insert(:contest, round: 2, host: build(:host, name: "C"), deadline: tomorrow)

      assert Foundation.list_open_contests(2) == [c2, c1, c3]
    end

    test "does not return contests with a past signup deadline" do
      yesterday = Timex.today |> Timex.shift(days: -1)
      insert(:contest, round: 0, deadline: yesterday)
      insert(:contest, round: 1, deadline: yesterday)

      assert Foundation.list_open_contests(0) == []
      assert Foundation.list_open_contests(1) == []
    end
  end

  describe "list_public_contests/1" do
    test "returns all contests with public timetables and 1+ scheduled performance" do
      %{stages: [s]} = host_with_stage = insert(:host, stages: build_list(1, :stage))

      # Matching contest
      c1 = insert(:contest, host: host_with_stage, timetables_public: true)
      insert_performance(c1, stage: s)

      # Non-matching contests
      insert(:contest, timetables_public: true)
      insert(:contest, host: host_with_stage, timetables_public: true)
      c2 = insert(:contest, host: host_with_stage, timetables_public: false)
      insert_performance(c2, stage: s)

      assert_ids_match_unordered Foundation.list_public_contests, [c1]
    end

    test "preloads the contests' hosts with used stages, as well as contest categories" do
      [s1, s2, _] = stages = insert_list(3, :stage)
      host = insert(:host, stages: stages)
      c = insert(:contest, host: host, contest_categories: [], timetables_public: true)
      cc = insert_contest_category(c)

      # Keep third stage unused
      insert_performance(cc, stage: s1)
      insert_performance(cc, stage: s2)

      [result] = Foundation.list_public_contests
      assert %Contest{
        host: %Host{stages: result_stages},
        contest_categories: [%ContestCategory{category: %Category{}}]
      } = result
      assert_ids_match_unordered result_stages, [s1, s2]
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

    test "returns a Kimu contest with the same season and host as a given RW contest", %{host: h, season: s} do
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
      insert(:contest, host: build(:host), season: s, round: 0) # Wrong host
      insert(:contest, host: h, season: s + 1, round: 0) # Wrong season
      insert(:contest, host: h, season: s, round: 2) # Wrong round
      rw = insert(:contest, host: h, season: s, round: 1)

      assert Foundation.get_matching_kimu_contest(rw) == nil
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
        build(:contest, deadline: d3),
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
        build(:contest, deadline: d1),
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
        category: %Category{},
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
      %{id: id} = insert(:contest, host: build(:host, users: [
        build(:user, given_name: "A"),
        build(:user, given_name: "B"),
      ]))

      contest = Repo.get(Contest, id) |> Foundation.load_host_users
      assert [%User{given_name: "A"}, %User{given_name: "B"}] = contest.host.users
    end
  end

  test "load_contest_categories/1 preloads a contest's contest categories" do
    %{id: id} = insert(:contest,
      contest_categories: build_list(1, :contest_category,
        category: build(:category, name: "ABC")
      )
    )

    contest = Repo.get(Contest, id) |> Foundation.load_contest_categories
    assert [%ContestCategory{category: %Category{name: "ABC"}}] = contest.contest_categories
  end

  test "load_stages/1 preloads a contest's stages" do
    %{id: id} = insert(:contest,
      host: build(:host, stages: build_list(1, :stage, name: "X"))
    )

    contest = Repo.get(Contest, id) |> Foundation.load_stages
    assert [%Stage{name: "X"}] = contest.host.stages
  end
end
