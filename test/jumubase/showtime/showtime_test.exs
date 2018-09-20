defmodule Jumubase.ShowtimeTest do
  use Jumubase.DataCase
  alias Jumubase.Foundation.{Category, ContestCategory}
  alias Jumubase.Showtime
  alias Jumubase.Showtime.{Appearance, Performance, Participant}

  describe "performances" do
    test "list_performances/1 returns the given contest's performances" do
      contest = insert(:contest)

      # Performances in this contest
      [cc1, cc2] = insert_list(2, :contest_category, contest: contest)
      [p1, p2] = insert_list(2, :performance, contest_category: cc1)
      p3 = insert(:performance, contest_category: cc2)

      # Performance in other contest
      insert(:performance)

      assert_ids_match_unordered Showtime.list_performances(contest), [p1, p2, p3]
    end

    test "list_performances/1 preloads the performances' contest categories + categories" do
      %{contest_category: %{contest: c}} = insert(:performance)

      assert [%Performance{
        contest_category: %ContestCategory{category: %Category{}}
      }] = Showtime.list_performances(c)
    end

    test "get_performance!/2 gets a performance from the given contest by id" do
      %{id: id, contest_category: %{contest: c}} = insert(:performance)

      result = Showtime.get_performance!(c, id)
      assert result.id == id
    end

    test "get_performance!/2 raises an error if the performance isn't found in the given contest" do
      c = insert(:contest)
      %{id: id} = insert(:performance)

      assert_raise Ecto.NoResultsError, fn -> Showtime.get_performance!(c, id) end
    end

    test "get_performance!/2 preloads all associated data of the performance" do
      %{
        id: id,
        contest_category: %{contest: c}
      } = insert(:performance, appearances: [
        build(:appearance, performance: nil)
      ])

      assert %Performance{
        contest_category: %ContestCategory{category: %Category{}},
        appearances: [%Appearance{participant: %Participant{}}]
      } = Showtime.get_performance!(c, id)
    end

    test "create_performance/1 creates a new performance" do
      attrs = valid_performance_attrs()

      assert {:ok, %Performance{} = performance} = Showtime.create_performance(attrs)
      assert Regex.match?(~r/^[0-9]{6}$/, performance.edit_code)
    end

    test "change_performance/1 returns a performance changeset" do
      performance = insert(:performance)
      assert %Ecto.Changeset{} = Showtime.change_performance(performance)
    end
  end
end
