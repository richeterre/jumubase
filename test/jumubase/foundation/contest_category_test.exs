defmodule Jumubase.ContestCategoryTest do
  use Jumubase.DataCase
  alias Jumubase.Foundation.ContestCategory

  @invalid_ags ["", "ii", "Ic", "VIII"]

  describe "changeset" do
    test "with valid attributes" do
      params = valid_params()
      changeset = ContestCategory.changeset(%ContestCategory{}, params)
      assert changeset.valid?
    end

    test "without an associated contest" do
      params = valid_params(contest: nil)
      changeset = ContestCategory.changeset(%ContestCategory{}, params)
      refute changeset.valid?
    end

    test "without an associated category" do
      params = valid_params(category: nil)
      changeset = ContestCategory.changeset(%ContestCategory{}, params)
      refute changeset.valid?
    end

    test "without a minimum age group" do
      params = valid_params(min_age_group: nil)
      changeset = ContestCategory.changeset(%ContestCategory{}, params)
      refute changeset.valid?
    end

    test "with an invalid minimum age group" do
      for invalid_ag <- @invalid_ags do
        params = valid_params(min_age_group: invalid_ag)
        changeset = ContestCategory.changeset(%ContestCategory{}, params)
        refute changeset.valid?
      end
    end

    test "without a maximum age group" do
      params = valid_params(max_age_group: nil)
      changeset = ContestCategory.changeset(%ContestCategory{}, params)
      refute changeset.valid?
    end

    test "with an invalid maximum age group" do
      for invalid_ag <- @invalid_ags do
        params = valid_params(max_age_group: invalid_ag)
        changeset = ContestCategory.changeset(%ContestCategory{}, params)
        refute changeset.valid?
      end
    end

    test "with an invalid minimum advancing age group" do
      for invalid_ag <- @invalid_ags do
        params = valid_params(min_advancing_age_group: invalid_ag)
        changeset = ContestCategory.changeset(%ContestCategory{}, params)
        refute changeset.valid?
      end
    end

    test "with an invalid maximum advancing age group" do
      for invalid_ag <- @invalid_ags do
        params = valid_params(max_advancing_age_group: invalid_ag)
        changeset = ContestCategory.changeset(%ContestCategory{}, params)
        refute changeset.valid?
      end
    end
  end

  # Private helpers

  defp valid_params(override_attrs \\ []) do
    attrs =
      [contest: build(:contest)]
      |> Keyword.merge(override_attrs)

    params_with_assocs(:contest_category, attrs)
  end
end
