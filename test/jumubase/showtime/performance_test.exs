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
      assert changeset.errors[:base] == {"The performance must have at least one participant", []}
    end

    test "without a piece", %{valid_attrs: valid_attrs} do
      params = Map.put(valid_attrs, :pieces, [])
      changeset = Performance.changeset(%Performance{}, params)
      refute changeset.valid?
      assert changeset.errors[:base] == {"The performance must have at least one piece", []}
    end
  end

  describe "to_edit_code/1" do
    test "generates a zero-padded edit code string" do
      assert Performance.to_edit_code(123) == "000123"
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
end
