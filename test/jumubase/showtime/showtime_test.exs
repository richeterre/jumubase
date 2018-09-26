defmodule Jumubase.ShowtimeTest do
  use Jumubase.DataCase
  alias Ecto.Changeset
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

    test "create_performance/2 creates a new performance with an edit code" do
      {cc, attrs} = performance_params([
        appearance_params("soloist", ~D[2007-01-01])
      ])

      assert {:ok, %Performance{edit_code: edit_code}} = Showtime.create_performance(cc.contest, attrs)
      assert Regex.match?(~r/^[0-9]{6}$/, edit_code)
    end

    test "create_performance/2 sets no edit code when the data is invalid" do
      {cc, attrs} = performance_params([])
      {:error, changeset} = Showtime.create_performance(cc.contest, attrs)

      assert Changeset.get_change(changeset, :edit_code) == nil
    end

    test "create_performance/2 assigns a joint age group based on non-accompanists" do
      {cc, attrs} = performance_params([
        appearance_params("ensemblist", ~D[2006-12-31]),
        appearance_params("ensemblist", ~D[2007-01-01]),
        appearance_params("accompanist", ~D[2000-01-01]) # should not affect age group
      ])
      {:ok, performance} = Showtime.create_performance(cc.contest, attrs)

      assert performance.age_group == "III"
    end

    test "create_performance/2 assigns the correct age groups for a classical solo performance" do
      cc = insert(:contest_category, category: build(:category, genre: "classical"))
      {cc, attrs} = performance_params([
        appearance_params("soloist", ~D[2007-01-01]),
        appearance_params("accompanist", ~D[2000-01-01]),
        appearance_params("accompanist", ~D[2002-01-02])
      ], cc)
      {:ok, performance} = Showtime.create_performance(cc.contest, attrs)

      sol = get_soloist(performance)
      assert sol.age_group == "II"

      [acc1, acc2] = get_accompanists(performance)
      assert acc1.age_group == "VI"
      assert acc2.age_group == "V"
    end

    test "create_performance/2 assigns the correct age groups for a classical ensemble performance" do
      cc = insert(:contest_category, category: build(:category, genre: "classical"))
      {cc, attrs} = performance_params([
        appearance_params("ensemblist", ~D[2006-12-31]),
        appearance_params("ensemblist", ~D[2007-01-01]),
        appearance_params("accompanist", ~D[2000-01-01]),
        appearance_params("accompanist", ~D[2002-01-02])
      ], cc)
      {:ok, performance} = Showtime.create_performance(cc.contest, attrs)

      [ens1, ens2] = get_ensemblists(performance)
      assert ens1.age_group == "III"
      assert ens2.age_group == "III"

      [acc1, acc2] = get_accompanists(performance)
      assert acc1.age_group == "VI"
      assert acc2.age_group == "V"
    end

    test "create_performance/2 assigns the correct age groups for a pop solo performance" do
      cc = insert(:contest_category, category: build(:category, genre: "popular"))
      {cc, attrs} = performance_params([
        appearance_params("soloist", ~D[2007-01-01]),
        appearance_params("accompanist", ~D[2000-01-01]),
        appearance_params("accompanist", ~D[2002-01-02])
      ], cc)
      {:ok, performance} = Showtime.create_performance(cc.contest, attrs)

      sol = get_soloist(performance)
      assert sol.age_group == "II"

      [acc1, acc2] =  get_accompanists(performance)
      assert acc1.age_group == "V"
      assert acc2.age_group == "V"
    end

    test "create_performance/2 assigns the correct age groups for a pop ensemble performance" do
      cc = insert(:contest_category, category: build(:category, genre: "popular"))
      {cc, attrs} = performance_params([
        appearance_params("ensemblist", ~D[2006-12-31]),
        appearance_params("ensemblist", ~D[2007-01-01]),
        appearance_params("accompanist", ~D[2000-01-01]),
        appearance_params("accompanist", ~D[2002-01-02])
      ], cc)
      {:ok, performance} = Showtime.create_performance(cc.contest, attrs)

      [ens1, ens2] = get_ensemblists(performance)
      assert ens1.age_group == "III"
      assert ens2.age_group == "III"

      [acc1, acc2] = get_accompanists(performance)
      assert acc1.age_group == "V"
      assert acc2.age_group == "V"
    end

    test "create_performance/2 sets no age group when the data is invalid" do
      {cc, attrs} = performance_params([])
      {:error, changeset} = Showtime.create_performance(cc.contest, attrs)

      assert Changeset.get_change(changeset, :age_group) == nil
    end

    test "create_performance/2 returns an error when passing no contest category id" do
      contest = insert(:contest)
      assert {:error, _changeset} = Showtime.create_performance(contest, %{contest_category_id: nil})
    end

    test "create_performance/2 raises an error when the passed contest and attributes don't match" do
      {_, attrs} = performance_params([
        appearance_params("soloist", ~D[2007-01-01])
      ])
      other_contest = insert(:contest)
      assert_raise Ecto.NoResultsError, fn -> Showtime.create_performance(other_contest, attrs) end
    end

    test "change_performance/1 returns a performance changeset" do
      performance = insert(:performance)
      assert %Changeset{} = Showtime.change_performance(performance)
    end
  end

  # Private helpers

  defp performance_params(appearances_params) do
    cc = insert(:contest_category)
    performance_params(appearances_params, cc)
  end
  defp performance_params(appearances_params, contest_category) do
    attrs = %{
      contest_category_id: contest_category.id,
      appearances: appearances_params
    }
    {contest_category, attrs}
  end

  defp appearance_params(role, participant_birthdate) do
    %{
      role: role,
      instrument: "vocals",
      participant: params_for(:participant, birthdate: participant_birthdate)
    }
  end

  defp get_soloist(%Performance{appearances: appearances}) do
    Enum.find(appearances, &Appearance.is_soloist/1)
  end

  defp get_ensemblists(%Performance{appearances: appearances}) do
    Enum.filter(appearances, &Appearance.is_ensemblist/1)
  end

  defp get_accompanists(%Performance{appearances: appearances}) do
    Enum.filter(appearances, &Appearance.is_accompanist/1)
  end
end
