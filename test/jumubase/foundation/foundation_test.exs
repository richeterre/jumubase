defmodule Jumubase.FoundationTest do
  use Jumubase.DataCase
  alias Jumubase.Foundation
  alias Jumubase.Foundation.{Category, ContestCategory, Host}

  test "list_hosts/0 returns all hosts" do
    host = insert(:host)
    assert Foundation.list_hosts() == [host]
  end

  test "list_hosts/1 returns the hosts with the given ids" do
    [_h1, h2, h3] = insert_list(3, :host)
    assert Foundation.list_hosts([h2.id, h3.id]) == [h2, h3]
  end

  describe "list_contests/0" do
    test "returns all contests" do
      contests = insert_list(2, :contest)
      assert Foundation.list_contests == contests
    end

    test "preloads the contests' hosts" do
      insert(:contest)
      [result] = Foundation.list_contests
      assert %Host{} = result.host
    end
  end

  describe "list_open_contests/0" do
    test "returns contests the user can register for" do
      c1 = insert(:contest, deadline: Timex.today |> Timex.shift(days: 1))
      c2 = insert(:contest, deadline: Timex.today)
      assert Foundation.list_open_contests == [c1, c2]
    end

    test "does not return contests with a past signup deadline" do
      insert(:contest, deadline: Timex.today |> Timex.shift(days: -1))
      assert Foundation.list_open_contests == []
    end

    test "does not return 2nd round contests" do
      insert(:contest, deadline: Timex.today, round: 2)
      assert Foundation.list_open_contests == []
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

  test "load_contest_categories/1 preloads a contest's contest categories" do
    contest = build(:contest,
      contest_categories: build_list(1, :contest_category,
        category: build(:category, name: "ABC")
      )
    )

    %{id: id} = contest = Foundation.load_contest_categories(contest)
    assert [%{contest_id: ^id, category: %Category{name: "ABC"}}] = contest.contest_categories
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
end
