defmodule Jumubase.PerformanceTest do
  use Jumubase.DataCase
  alias Jumubase.Showtime.Performance

  describe "changeset" do
    setup do
      c = insert(:contest) |> with_contest_categories
      [cc, _] = c.contest_categories
      [valid_attrs: valid_performance_attrs(cc)]
    end

    test "with valid attributes", %{valid_attrs: valid_attrs} do
      changeset = Performance.changeset(%Performance{}, valid_attrs)
      assert changeset.valid?
    end

    test "without an associated contest category", %{valid_attrs: valid_attrs} do
      params = Map.put(valid_attrs, :contest_category_id, nil)
      changeset = Performance.changeset(%Performance{}, params)
      refute changeset.valid?
    end

    test "without an appearance", %{valid_attrs: valid_attrs} do
      params = Map.put(valid_attrs, :appearances, [])
      changeset = Performance.changeset(%Performance{}, params)
      refute changeset.valid?
      assert changeset.errors[:base] == {"The performance must have at least one participant.", []}
    end

    test "with both soloist and ensemblist appearances", %{valid_attrs: valid_attrs} do
      params = Map.put(valid_attrs, :appearances, [
        valid_appearance_attrs("soloist"),
        valid_appearance_attrs("ensemblist"),
      ])
      changeset = Performance.changeset(%Performance{}, params)
      refute changeset.valid?
      assert changeset.errors[:base] == {"The performance can't have both soloists and ensemblists.", []}
    end

    test "with multiple soloist appearances", %{valid_attrs: valid_attrs} do
      params = Map.put(valid_attrs, :appearances, [
        valid_appearance_attrs("soloist"),
        valid_appearance_attrs("soloist"),
      ])
      changeset = Performance.changeset(%Performance{}, params)
      refute changeset.valid?
      assert changeset.errors[:base] == {"The performance can't have more than one soloist.", []}
    end

    test "with a single ensemblist appearance", %{valid_attrs: valid_attrs} do
      params = Map.put(valid_attrs, :appearances, [
        valid_appearance_attrs("ensemblist"),
        valid_appearance_attrs("accompanist"),
      ])
      changeset = Performance.changeset(%Performance{}, params)
      refute changeset.valid?
      assert changeset.errors[:base] == {"The performance can't have only one ensemblist.", []}
    end

    test "with only accompanist appearances", %{valid_attrs: valid_attrs} do
      params = Map.put(valid_attrs, :appearances, [
        valid_appearance_attrs("accompanist"),
        valid_appearance_attrs("accompanist"),
      ])
      changeset = Performance.changeset(%Performance{}, params)
      refute changeset.valid?
      assert changeset.errors[:base] == {"The performance can't have only accompanists.", []}
    end

    test "without a piece", %{valid_attrs: valid_attrs} do
      params = Map.put(valid_attrs, :pieces, [])
      changeset = Performance.changeset(%Performance{}, params)
      refute changeset.valid?
      assert changeset.errors[:base] == {"The performance must have at least one piece.", []}
    end
  end

  describe "to_edit_code/2" do
    test "generates an edit code string for a Kimu performance" do
      assert Performance.to_edit_code(123, 0) == "000123"
    end

    test "generates an edit code string for an RW performance" do
      assert Performance.to_edit_code(123, 1) == "100123"
    end

    test "generates an edit code string for an LW performance" do
      assert Performance.to_edit_code(123, 2) == "200123"
    end
  end

  # Private helpers

  defp valid_performance_attrs(contest_category) do
    params_for(:performance, edit_code: nil, age_group: nil)
    |> Map.put(:contest_category_id, contest_category.id)
    |> Map.put(:appearances, [valid_appearance_attrs()])
    |> Map.put(:pieces, [params_for(:piece)])
  end

  defp valid_appearance_attrs do
    params_for(:appearance)
    |> Map.put(:participant, params_for(:participant))
  end
  defp valid_appearance_attrs(role) do
    params_for(:appearance, role: role)
    |> Map.put(:participant, params_for(:participant))
  end
end
