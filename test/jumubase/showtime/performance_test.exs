defmodule Jumubase.PerformanceTest do
  use Jumubase.DataCase
  alias Jumubase.Showtime.Performance

  describe "changeset" do
    setup %{} do
      attrs =
        params_with_assocs(:performance)
        |> Map.put(:appearances, [valid_appearance_attrs()])

      [valid_attrs: attrs]
    end

    test "with valid attributes", %{valid_attrs: valid_attrs} do
      changeset = Performance.changeset(%Performance{}, valid_attrs)
      assert changeset.valid?
    end

    test "without an associated contest category" do
      params = params_with_assocs(:performance, contest_category: nil)
      changeset = Performance.changeset(%Performance{}, params)
      refute changeset.valid?
    end
  end

  describe "to_edit_code/1" do
    test "generates a zero-padded edit code string" do
      assert Performance.to_edit_code(123) == "000123"
    end
  end
end
