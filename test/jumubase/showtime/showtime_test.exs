defmodule Jumubase.ShowtimeTest do
  use Jumubase.DataCase
  alias Ecto.Changeset
  alias Jumubase.Foundation.{Category, Contest, ContestCategory}
  alias Jumubase.Showtime
  alias Jumubase.Showtime.{Appearance, Participant, Performance, Piece}

  setup do
    [contest: insert(:contest) |> with_contest_categories]
  end

  describe "list_performances/1" do
    test "returns the given contest's performances", %{contest: c} do
      # Performances in this contest
      [cc1, cc2] = c.contest_categories
      [p1, p2] = insert_list(2, :performance, contest_category: cc1)
      p3 = insert(:performance, contest_category: cc2)

      # Performance in other contest
      other_c = insert(:contest)
      insert_performance(other_c)

      assert_ids_match_unordered Showtime.list_performances(c), [p1, p2, p3]
    end

    test "preloads the performances' contest categories + categories", %{contest: c} do
      insert_performance(c)

      assert [%Performance{
        contest_category: %ContestCategory{category: %Category{}}
      }] = Showtime.list_performances(c)
    end
  end

  describe "get_performance!/2" do
    test "gets a performance from the given contest by id", %{contest: c} do
      %{id: id} = insert_performance(c)

      result = Showtime.get_performance!(c, id)
      assert result.id == id
    end

    test "raises an error if the performance isn't found in the given contest", %{contest: c} do
      %{id: id} = insert_performance(c)
      other_c = insert(:contest)

      assert_raise Ecto.NoResultsError, fn -> Showtime.get_performance!(other_c, id) end
    end

    test "preloads all associated data of the performance", %{contest: c} do
      %{id: id} = insert_performance(c)

      assert %Performance{
        contest_category: %ContestCategory{category: %Category{}},
        appearances: [%Appearance{participant: %Participant{}}],
        pieces: [%Piece{}]
      } = Showtime.get_performance!(c, id)
    end
  end

  describe "get_performance!/3" do
    test "gets a performance from the given contest by id and edit code", %{contest: c} do
      %{id: id, edit_code: edit_code} = insert_performance(c)

      result = Showtime.get_performance!(c, id, edit_code)
      assert result.id == id
    end

    test "raises an error if the contest doesn't match", %{contest: c} do
      other_c = insert(:contest)
      %{id: id, edit_code: edit_code} = insert_performance(c)

      assert_raise Ecto.NoResultsError, fn ->
        Showtime.get_performance!(other_c, id, edit_code)
      end
    end

    test "raises an error if the edit code doesn't match", %{contest: c} do
      %{id: id} = insert_performance(c)

      assert_raise Ecto.NoResultsError, fn ->
        Showtime.get_performance!(c, id, "unknown")
      end
    end

    test "preloads all associated data of the performance", %{contest: c} do
      %{id: id, edit_code: edit_code} = insert_performance(c)

      assert %Performance{
        contest_category: %ContestCategory{category: %Category{}},
        appearances: [%Appearance{participant: %Participant{}}],
        pieces: [%Piece{}]
      } = Showtime.get_performance!(c, id, edit_code)
    end
  end

  describe "lookup_performance/1" do
    test "gets a performance by its edit code", %{contest: c} do
      %{id: id, edit_code: edit_code} = insert_performance(c)

      assert {:ok, result} = Showtime.lookup_performance(edit_code)
      assert result.id == id
    end

    test "preloads the performance's contest category and contest", %{contest: c} do
      %{edit_code: edit_code} = insert_performance(c)

      assert {:ok, %Performance{
        contest_category: %ContestCategory{contest: %Contest{}},
      }} = Showtime.lookup_performance(edit_code)
    end

    test "returns an error for an unknown edit code" do
      assert {:error, :not_found} = Showtime.lookup_performance("unknown")
    end
  end

  describe "lookup_performance!/2" do
    test "gets a performance from the given contest by edit code", %{contest: c} do
      %{id: id, edit_code: edit_code} = insert_performance(c)

      result = Showtime.lookup_performance!(c, edit_code)
      assert result.id == id
    end

    test "raises an error if the performance isn't found in the given contest", %{contest: c} do
      other_c = insert(:contest)
      %{edit_code: edit_code} = insert_performance(c)

      assert_raise Ecto.NoResultsError, fn -> Showtime.lookup_performance!(other_c, edit_code) end
    end

    test "preloads all associated data of the performance", %{contest: c} do
      %{edit_code: edit_code} = insert_performance(c)

      assert %Performance{
        contest_category: %ContestCategory{category: %Category{}},
        appearances: [%Appearance{participant: %Participant{}}],
        pieces: [%Piece{}]
      } = Showtime.lookup_performance!(c, edit_code)
    end
  end

  describe "create_performance/2" do
    test "creates a new performance with an edit code", %{contest: c} do
      [cc, _] = c.contest_categories
      attrs = performance_params(cc, [
        appearance_params("soloist", ~D[2007-01-01])
      ])

      assert {:ok, %Performance{edit_code: edit_code}} = Showtime.create_performance(c, attrs)
      assert Regex.match?(~r/^[0-9]{6}$/, edit_code)
    end

    test "sets no edit code when the data is invalid", %{contest: c} do
      [cc, _] = c.contest_categories
      attrs = performance_params(cc, [])
      {:error, changeset} = Showtime.create_performance(c, attrs)

      assert Changeset.get_change(changeset, :edit_code) == nil
    end

    test "assigns a joint age group based on non-accompanists", %{contest: c} do
      [cc, _] = c.contest_categories
      attrs = performance_params(cc, [
        appearance_params("ensemblist", ~D[2006-12-31]),
        appearance_params("ensemblist", ~D[2007-01-01]),
        appearance_params("accompanist", ~D[2000-01-01]) # should not affect age group
      ])
      {:ok, performance} = Showtime.create_performance(c, attrs)

      assert performance.age_group == "III"
    end

    test "assigns the correct age groups for a classical solo performance", %{contest: c} do
      cc = insert_contest_category(c, "classical")
      attrs = performance_params(cc, [
        appearance_params("soloist", ~D[2007-01-01]),
        appearance_params("accompanist", ~D[2000-01-01]),
        appearance_params("accompanist", ~D[2002-01-02])
      ])
      {:ok, performance} = Showtime.create_performance(c, attrs)

      sol = get_soloist(performance)
      assert sol.age_group == "II"

      [acc1, acc2] = get_accompanists(performance)
      assert acc1.age_group == "VI"
      assert acc2.age_group == "V"
    end

    test "assigns the correct age groups for a classical ensemble performance", %{contest: c} do
      cc = insert_contest_category(c, "classical")
      attrs = performance_params(cc, [
        appearance_params("ensemblist", ~D[2006-12-31]),
        appearance_params("ensemblist", ~D[2007-01-01]),
        appearance_params("accompanist", ~D[2000-01-01]),
        appearance_params("accompanist", ~D[2002-01-02])
      ])
      {:ok, performance} = Showtime.create_performance(c, attrs)

      [ens1, ens2] = get_ensemblists(performance)
      assert ens1.age_group == "III"
      assert ens2.age_group == "III"

      [acc1, acc2] = get_accompanists(performance)
      assert acc1.age_group == "VI"
      assert acc2.age_group == "V"
    end

    test "assigns the correct age groups for a pop solo performance", %{contest: c} do
      cc = insert_contest_category(c, "popular")
      attrs = performance_params(cc, [
        appearance_params("soloist", ~D[2007-01-01]),
        appearance_params("accompanist", ~D[2000-01-01]),
        appearance_params("accompanist", ~D[2002-01-02])
      ])
      {:ok, performance} = Showtime.create_performance(c, attrs)

      sol = get_soloist(performance)
      assert sol.age_group == "II"

      [acc1, acc2] = get_accompanists(performance)
      assert acc1.age_group == "V"
      assert acc2.age_group == "V"
    end

    test "assigns the correct age groups for a pop ensemble performance", %{contest: c} do
      cc = insert_contest_category(c, "popular")
      attrs = performance_params(cc, [
        appearance_params("ensemblist", ~D[2006-12-31]),
        appearance_params("ensemblist", ~D[2007-01-01]),
        appearance_params("accompanist", ~D[2000-01-01]),
        appearance_params("accompanist", ~D[2002-01-02])
      ])
      {:ok, performance} = Showtime.create_performance(c, attrs)

      [ens1, ens2] = get_ensemblists(performance)
      assert ens1.age_group == "III"
      assert ens2.age_group == "III"

      [acc1, acc2] = get_accompanists(performance)
      assert acc1.age_group == "V"
      assert acc2.age_group == "V"
    end

    test "sets no age group when the data is invalid", %{contest: c} do
      [cc, _] = c.contest_categories
      attrs = performance_params(cc, [])
      {:error, changeset} = Showtime.create_performance(c, attrs)

      assert Changeset.get_change(changeset, :age_group) == nil
    end

    test "returns an error when passing no contest category id", %{contest: c} do
      assert {:error, _changeset} = Showtime.create_performance(c, %{contest_category_id: nil})
    end

    test "raises an error when the passed contest and attributes don't match", %{contest: c} do
      [cc, _] = c.contest_categories
      attrs = performance_params(cc, [
        appearance_params("soloist", ~D[2007-01-01])
      ])
      other_c = insert(:contest)
      assert_raise Ecto.NoResultsError, fn -> Showtime.create_performance(other_c, attrs) end
    end
  end

  test "change_performance/1 returns a performance changeset", %{contest: c} do
    performance = insert_performance(c)
    assert %Changeset{} = Showtime.change_performance(performance)
  end

  # Private helpers

  defp performance_params(contest_category, appearances_params) do
    %{
      contest_category_id: contest_category.id,
      appearances: appearances_params,
      pieces: [params_for(:piece)]
    }
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
